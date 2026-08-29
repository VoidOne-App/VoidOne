#include "SteamScanner.h"
#include <QDir>
#include <QFile>
#include <QTextStream>
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

    const QStringList exeFiles = dir.entryList(QStringList() << "*.exe", QDir::Files);
    if (exeFiles.isEmpty()) {
        qWarning() << "[VoidOne] No .exe files found in:" << gameDir;
        return QString();
    }

    // Pass 1: prefer an exe whose stem matches the game name (case-insensitive)
    const QString lowerName = gameName.toLower();
    for (const QString &f : exeFiles) {
        if (QFileInfo(f).completeBaseName().toLower() == lowerName)
            return dir.absoluteFilePath(f);
    }

    // Pass 2: single .exe in the root — use it
    if (exeFiles.size() == 1)
        return dir.absoluteFilePath(exeFiles.first());

    // Pass 3: filter out known non-game executables, then pick the largest remaining
    // (game executables are typically larger than launchers, crash reporters, uninstallers)
    QList<QPair<qint64, QString>> candidates;
    for (const QString &f : exeFiles) {
        if (isLikelyNonGameExe(f)) continue;
        QFileInfo fi(dir.absoluteFilePath(f));
        candidates.append({fi.size(), f});
    }

    if (!candidates.isEmpty()) {
        std::sort(candidates.begin(), candidates.end(),
                  [](const auto &a, const auto &b) { return a.first > b.first; });
        return dir.absoluteFilePath(candidates.first().second);
    }

    // Pass 4 (last resort): if all exes looked like non-game executables,
    // still pick the largest one rather than returning the directory
    QList<QPair<qint64, QString>> allBySize;
    for (const QString &f : exeFiles) {
        QFileInfo fi(dir.absoluteFilePath(f));
        allBySize.append({fi.size(), f});
    }
    std::sort(allBySize.begin(), allBySize.end(),
              [](const auto &a, const auto &b) { return a.first > b.first; });
    qWarning() << "[VoidOne] No ideal exe match for" << gameName
               << "; falling back to largest exe:" << allBySize.first().second;
    return dir.absoluteFilePath(allBySize.first().second);
}
#endif

void SteamScannerWorker::doScan() {
    QVector<GameRecord> games;
    QString steamPath = "";

#if defined(Q_OS_WIN)
    steamPath = "C:/Program Files (x86)/Steam";
#elif defined(Q_OS_LINUX)
    QString home = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    steamPath = home + "/.local/share/Steam";
    if (!QDir(steamPath).exists()) {
        steamPath = home + "/.var/app/com.valvesoftware.Steam/.local/share/Steam";
    }
#endif

    QString steamappsPath = steamPath + "/steamapps";
    QDir steamappsDir(steamappsPath);

    if (steamappsDir.exists()) {
        QStringList filters;
        filters << "appmanifest_*.acf";
        QFileInfoList manifestFiles = steamappsDir.entryInfoList(filters, QDir::Files);

        QRegularExpression nameRx("\"name\"\\s+\"([^\"]+)\"");
        QRegularExpression dirRx("\"installdir\"\\s+\"([^\"]+)\"");

        for (const QFileInfo &fileInfo : manifestFiles) {
            QFile file(fileInfo.absoluteFilePath());
            if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
                QString content = file.readAll();
                file.close();

                auto nameMatch = nameRx.match(content);
                auto dirMatch = dirRx.match(content);

                if (nameMatch.hasMatch() && dirMatch.hasMatch()) {
                    GameRecord rec;
                    rec.name = nameMatch.captured(1);
                    const QString gameDir = steamappsPath + "/common/" + dirMatch.captured(1);
#if defined(Q_OS_WIN)
                    rec.exePath = findMainExecutable(gameDir, rec.name);
#else
                    rec.exePath = gameDir;
#endif
                    rec.platform = "Steam";
                    games.append(rec);
                }
            }
        }
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
}

void SteamScanner::startAsyncScan() {
    if (!workerThread.isRunning() || worker == nullptr) {
        qWarning() << "[VoidOne] Steam scanner worker thread is not available.";
        emit scanCompleted(0);
        return;
    }

    QMetaObject::invokeMethod(worker, &SteamScannerWorker::doScan, Qt::QueuedConnection);
}

void SteamScanner::handleScanFinished(const QVector<GameRecord>& games) {
    Database::addGamesBatch(games);
    emit scanCompleted(games.size());
}
