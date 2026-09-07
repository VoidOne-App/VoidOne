#include "SteamScanner.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QRegularExpression>
#include <QDebug>
#include <algorithm>

#if defined(Q_OS_WIN)
static bool isLikelyNonGameExe(const QString &fileName) {
    static const QStringList prefixes = {
        "uninstall", "setup", "redist", "vcredist",
        "dxsetup", "dotnet", "install", "remove"
    };
    static const QStringList substrings = {
        "uninstall", "setup", "redist", "crashhandler",
        "crash_handler", "launcher", "updater", "patcher",
        "helper", "service", "agent", "installer"
    };
    const QString lower = fileName.toLower();
    for (const QString &p : prefixes) {
        if (lower.startsWith(p)) return true;
    }
    for (const QString &s : substrings) {
        if (lower.contains(s)) return true;
    }
    return false;
}

static QString findMainExecutable(const QString &gameDir, const QString &gameName) {
    QDir dir(gameDir);
    if (!dir.exists()) {
        qWarning() << "[VoidOne] Game directory does not exist:" << gameDir;
        return QString();
    }

    const QStringList rootExeFiles = dir.entryList(QStringList() << "*.exe", QDir::Files);
    const QString lowerName = gameName.toLower();

    for (const QString &f : rootExeFiles) {
        if (QFileInfo(f).completeBaseName().toLower() == lowerName)
            return dir.absoluteFilePath(f);
    }

    QList<QPair<qint64, QString>> candidates;
    for (const QString &f : rootExeFiles) {
        if (isLikelyNonGameExe(f)) continue;
        const QFileInfo fi(dir.absoluteFilePath(f));
        candidates.append({fi.size(), fi.absoluteFilePath()});
    }

    // Search one level deeper for common modern game layouts such as
    // Binaries/Win64 or bin/win64. Avoid an unrestricted recursive scan.
    const QFileInfoList childDirs = dir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);
    for (const QFileInfo &child : childDirs) {
        const QDir childDir(child.absoluteFilePath());
        const QStringList childExes = childDir.entryList(QStringList() << "*.exe", QDir::Files);
        for (const QString &f : childExes) {
            if (isLikelyNonGameExe(f)) continue;
            const QFileInfo fi(childDir.absoluteFilePath(f));
            const QString stem = fi.completeBaseName().toLower();
            if (stem == lowerName)
                return fi.absoluteFilePath();
            candidates.append({fi.size(), fi.absoluteFilePath()});
        }
    }

    if (!candidates.isEmpty()) {
        std::sort(candidates.begin(), candidates.end(),
                  [](const auto &a, const auto &b) { return a.first > b.first; });
        return candidates.first().second;
    }

    qWarning() << "[VoidOne] No game executable found in:" << gameDir;
    return QString();
}
#endif

void SteamScannerWorker::doScan() {
    QVector<GameRecord> games;
    QString steamPath;

#if defined(Q_OS_WIN)
    steamPath = "C:/Program Files (x86)/Steam";
#elif defined(Q_OS_LINUX)
    const QString home = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    steamPath = home + "/.local/share/Steam";
    if (!QDir(steamPath).exists())
        steamPath = home + "/.var/app/com.valvesoftware.Steam/.local/share/Steam";
#endif

    const QString steamappsPath = steamPath + "/steamapps";
    const QDir steamappsDir(steamappsPath);
    if (!steamappsDir.exists()) {
        emit scanFinished({});
        return;
    }

    const QFileInfoList manifestFiles = steamappsDir.entryInfoList(
        {"appmanifest_*.acf"}, QDir::Files, QDir::Name);
    const QRegularExpression nameRx("\\\"name\\\"\\s+\\\"([^\\\"]+)\\\"");
    const QRegularExpression dirRx("\\\"installdir\\\"\\s+\\\"([^\\\"]+)\\\"");

    for (const QFileInfo &fileInfo : manifestFiles) {
        QFile file(fileInfo.absoluteFilePath());
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qWarning() << "[VoidOne] Failed to read Steam manifest:" << fileInfo.absoluteFilePath();
            continue;
        }

        const QString content = QString::fromUtf8(file.readAll());
        const auto nameMatch = nameRx.match(content);
        const auto dirMatch = dirRx.match(content);
        if (!nameMatch.hasMatch() || !dirMatch.hasMatch())
            continue;

        GameRecord rec;
        rec.name = nameMatch.captured(1).trimmed();
        const QString gameDir = QDir(steamappsPath).filePath("common/" + dirMatch.captured(1));
#if defined(Q_OS_WIN)
        rec.exePath = findMainExecutable(gameDir, rec.name);
#else
        rec.exePath = gameDir;
#endif
        rec.platform = "Steam";

        if (rec.name.isEmpty() || rec.exePath.isEmpty()) {
            qWarning() << "[VoidOne] Skipping Steam game with no usable executable:" << rec.name;
            continue;
        }
        games.append(rec);
    }

    emit scanFinished(games);
}

SteamScanner::SteamScanner(QObject *parent) : QObject(parent) {
    qRegisterMetaType<QVector<GameRecord>>("QVector<GameRecord>");
    worker = new SteamScannerWorker;
    worker->moveToThread(&workerThread);

    connect(&workerThread, &QThread::finished, worker, &QObject::deleteLater);
    connect(worker, &SteamScannerWorker::scanFinished, this, &SteamScanner::handleScanFinished);
    workerThread.start();
}

SteamScanner::~SteamScanner() {
    workerThread.quit();
    workerThread.wait();
    worker = nullptr;
}

void SteamScanner::startAsyncScan() {
    if (m_scanInProgress) {
        qWarning() << "[VoidOne] Steam scan already in progress; ignoring duplicate request.";
        return;
    }

    if (!workerThread.isRunning() || worker == nullptr) {
        qWarning() << "[VoidOne] Steam scanner worker thread is not available.";
        emit scanFailed("Steam scanner worker is unavailable.");
        return;
    }

    m_scanInProgress = true;
    QMetaObject::invokeMethod(worker, &SteamScannerWorker::doScan, Qt::QueuedConnection);
}

void SteamScanner::handleScanFinished(const QVector<GameRecord> &games) {
    const bool success = games.isEmpty() ? true : Database::addGamesBatch(games);
    m_scanInProgress = false;

    if (!success) {
        qWarning() << "[VoidOne] Steam scan completed, but database insertion failed.";
        emit scanFailed("Steam scan completed but the database could not save the results.");
        return;
    }

    emit scanCompleted(games.size());
}
