#include "SteamScanner.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QDebug>
#include <algorithm>
#include <functional>
#include <utility>

#ifdef Q_OS_WIN
#include <QSettings>
#endif

namespace {

Qt::CaseSensitivity pathCaseSensitivity()
{
#if defined(Q_OS_WIN)
    return Qt::CaseInsensitive;
#else
    return Qt::CaseSensitive;
#endif
}

QStringList uniqueExistingDirectories(const QStringList &paths)
{
    QStringList result;
    for (const QString &path : paths) {
        if (path.isEmpty())
            continue;
        const QString cleaned = QDir::cleanPath(path);
        if (QDir(cleaned).exists() && !result.contains(cleaned, pathCaseSensitivity()))
            result.append(cleaned);
    }
    return result;
}

QStringList discoverSteamRoots()
{
    QStringList roots;

    // Test/diagnostic override: a platform-independent root list lets integration tests
    // exercise the real scanner against isolated Steam-like directory trees.
    const QString overrideRoots = qEnvironmentVariable("VOIDONE_STEAM_ROOTS").trimmed();
    if (!overrideRoots.isEmpty()) {
        return uniqueExistingDirectories(overrideRoots.split(QDir::listSeparator(), Qt::SkipEmptyParts));
    }

#if defined(Q_OS_WIN)
    const QString programFilesX86 = qEnvironmentVariable("ProgramFiles(x86)");
    const QString programFiles = qEnvironmentVariable("ProgramFiles");
    const QString localAppData = qEnvironmentVariable("LOCALAPPDATA");

    roots << QDir(programFilesX86).filePath("Steam")
          << QDir(programFiles).filePath("Steam")
          << QDir(localAppData).filePath("Steam");

    // Steam commonly stores its install path in the Windows registry.
    const QStringList registryKeys = {
        QStringLiteral("HKEY_CURRENT_USER\\Software\\Valve\\Steam"),
        QStringLiteral("HKEY_LOCAL_MACHINE\\SOFTWARE\\WOW6432Node\\Valve\\Steam"),
        QStringLiteral("HKEY_LOCAL_MACHINE\\SOFTWARE\\Valve\\Steam")
    };
    for (const QString &key : registryKeys) {
        QSettings settings(key, QSettings::NativeFormat);
        const QString installPath = settings.value(QStringLiteral("SteamPath")).toString();
        if (!installPath.isEmpty())
            roots.append(installPath);
    }
#elif defined(Q_OS_LINUX)
    const QString home = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    roots << QDir(home).filePath(".local/share/Steam")
          << QDir(home).filePath(".steam/steam")
          << QDir(home).filePath(".steam/root")
          << QDir(home).filePath(".var/app/com.valvesoftware.Steam/.local/share/Steam");
#elif defined(Q_OS_MACOS)
    const QString home = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    roots << QDir(home).filePath("Library/Application Support/Steam");
#endif

    return uniqueExistingDirectories(roots);
}

QStringList discoverSteamLibraries(const QString &steamRoot)
{
    QStringList libraries;
    libraries << steamRoot;

    const QString libraryFile = QDir(steamRoot).filePath("steamapps/libraryfolders.vdf");
    QFile file(libraryFile);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return libraries;

    const QString content = QString::fromUtf8(file.readAll());
    // Valve's VDF contains entries such as: "path" "D:\\SteamLibrary".
    static const QRegularExpression pathRx(
        QStringLiteral("\"path\"\\s+\"([^\"]+)\""),
        QRegularExpression::CaseInsensitiveOption);

    auto match = pathRx.globalMatch(content);
    while (match.hasNext()) {
        QString path = match.next().captured(1).trimmed();
        path.replace(QStringLiteral("\\\\"), QStringLiteral("\\"));
        path = QDir::fromNativeSeparators(path);
        if (!path.isEmpty() && QDir(path).exists() && !libraries.contains(path, pathCaseSensitivity()))
            libraries.append(QDir::cleanPath(path));
    }

    return libraries;
}

bool isLikelyNonGameExecutable(const QString &fileName)
{
    static const QStringList blockedTokens = {
        QStringLiteral("uninstall"), QStringLiteral("setup"), QStringLiteral("redist"),
        QStringLiteral("vcredist"), QStringLiteral("dxsetup"), QStringLiteral("dotnet"),
        QStringLiteral("install"), QStringLiteral("remove"), QStringLiteral("crashhandler"),
        QStringLiteral("crash_handler"), QStringLiteral("launcher"), QStringLiteral("updater"),
        QStringLiteral("patcher"), QStringLiteral("helper"), QStringLiteral("service"),
        QStringLiteral("agent"), QStringLiteral("installer"), QStringLiteral("bootstrapper")
    };

    const QString lower = fileName.toLower();
    for (const QString &token : blockedTokens) {
        if (lower.contains(token))
            return true;
    }
    return false;
}

QString findMainExecutable(const QString &gameDir, const QString &gameName)
{
    QDir dir(gameDir);
    if (!dir.exists())
        return {};

#if defined(Q_OS_WIN)
    const QStringList filters = {QStringLiteral("*.exe")};
    const QDir::Filters fileFilters = QDir::Files | QDir::NoDotAndDotDot | QDir::NoSymLinks;
#else
    const QStringList filters = {QStringLiteral("*")};
    const QDir::Filters fileFilters = QDir::Files | QDir::Executable | QDir::NoDotAndDotDot | QDir::NoSymLinks;
#endif

    struct Candidate {
        int score = 0;
        qint64 size = 0;
        QString path;
    };
    QList<Candidate> candidates;

    const QString target = gameName.toLower().trimmed();

    auto inspect = [&](const QDir &scanDir, const QFileInfoList &files, int depth) {
        for (const QFileInfo &file : files) {
            if (!file.isFile() || file.isSymLink() || isLikelyNonGameExecutable(file.fileName()))
                continue;

#if !defined(Q_OS_WIN)
            if (!file.isExecutable())
                continue;
#endif

            const QString stem = file.completeBaseName().toLower();

            int score = 0;
            if (stem == target)
                score += 100;
            if (!target.isEmpty() && (stem.contains(target) || target.contains(stem)))
                score += 25;
            if (depth == 0)
                score += 15;
            else if (depth == 1)
                score += 8;

            // Size is only a tie-breaker, never the primary selection criterion.
            candidates.append({score, file.size(), file.absoluteFilePath()});
        }
    };

    std::function<void(const QDir &, int)> scanDirectory =
        [&](const QDir &scanDir, int depth) {
            inspect(scanDir, scanDir.entryInfoList(filters, fileFilters, QDir::Name), depth);
            if (depth >= 3)
                return;

            const QFileInfoList childDirs =
                scanDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot | QDir::NoSymLinks, QDir::Name);
            for (const QFileInfo &child : childDirs)
                scanDirectory(QDir(child.absoluteFilePath()), depth + 1);
        };

    scanDirectory(dir, 0);

    if (candidates.isEmpty())
        return {};

    std::sort(candidates.begin(), candidates.end(), [](const Candidate &a, const Candidate &b) {
        if (a.score != b.score)
            return a.score > b.score;
        if (a.size != b.size)
            return a.size > b.size;
        return a.path < b.path;
    });

    if (candidates.first().score < 15) {
        qWarning() << "[VoidOne] Executable discovery has low confidence for" << gameDir
                   << "candidate:" << candidates.first().path;
    }

    return candidates.first().path;
}

}

void SteamScannerWorker::doScan()
{
    QVector<GameRecord> games;

    const QStringList steamRoots = discoverSteamRoots();
    if (steamRoots.isEmpty()) {
        emit scanFinished({});
        return;
    }

    const QRegularExpression nameRx(
        QStringLiteral("\"name\"\\s+\"([^\"]+)\""),
        QRegularExpression::CaseInsensitiveOption);
    const QRegularExpression dirRx(
        QStringLiteral("\"installdir\"\\s+\"([^\"]+)\""),
        QRegularExpression::CaseInsensitiveOption);

    for (const QString &steamRoot : steamRoots) {
        const QStringList libraries = discoverSteamLibraries(steamRoot);

        for (const QString &library : libraries) {
            const QString steamappsPath = QDir(library).filePath("steamapps");
            const QDir steamappsDir(steamappsPath);
            if (!steamappsDir.exists())
                continue;

            const QFileInfoList manifestFiles = steamappsDir.entryInfoList(
                {QStringLiteral("appmanifest_*.acf")},
                QDir::Files | QDir::NoDotAndDotDot,
                QDir::Name);

            for (const QFileInfo &fileInfo : manifestFiles) {
                QFile file(fileInfo.absoluteFilePath());
                if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
                    qWarning() << "[VoidOne] Failed to read Steam manifest:"
                               << fileInfo.absoluteFilePath();
                    continue;
                }

                const QString content = QString::fromUtf8(file.readAll());
                const auto nameMatch = nameRx.match(content);
                const auto dirMatch = dirRx.match(content);
                if (!nameMatch.hasMatch() || !dirMatch.hasMatch())
                    continue;

                GameRecord rec;
                rec.name = nameMatch.captured(1).trimmed();
                const QString gameDir =
                    QDir(steamappsPath).filePath("common/" + dirMatch.captured(1));

                rec.exePath = findMainExecutable(gameDir, rec.name);
                rec.platform = QStringLiteral("Steam");

                if (rec.name.isEmpty() || rec.exePath.isEmpty()) {
                    qWarning() << "[VoidOne] Skipping Steam game with no usable executable:"
                               << rec.name << gameDir;
                    continue;
                }

                const QString canonicalExe = QFileInfo(rec.exePath).canonicalFilePath();
                if (!canonicalExe.isEmpty())
                    rec.exePath = canonicalExe;

                bool duplicate = false;
                for (const GameRecord &existing : std::as_const(games)) {
                    if (existing.exePath.compare(rec.exePath, pathCaseSensitivity()) == 0) {
                        duplicate = true;
                        break;
                    }
                }
                if (!duplicate)
                    games.append(rec);
            }
        }
    }

    emit scanFinished(games);
}

SteamScanner::SteamScanner(QObject *parent) : QObject(parent)
{
    qRegisterMetaType<QVector<GameRecord>>("QVector<GameRecord>");
    worker = new SteamScannerWorker;
    worker->moveToThread(&workerThread);

    connect(&workerThread, &QThread::finished, worker, &QObject::deleteLater);
    connect(worker, &SteamScannerWorker::scanFinished,
            this, &SteamScanner::handleScanFinished);
    workerThread.start();
}

SteamScanner::~SteamScanner()
{
    workerThread.quit();
    workerThread.wait();
    worker = nullptr;
}

void SteamScanner::startAsyncScan()
{
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

void SteamScanner::handleScanFinished(const QVector<GameRecord> &games)
{
    const bool success = games.isEmpty() ? true : Database::addGamesBatch(games);
    m_scanInProgress = false;

    if (!success) {
        qWarning() << "[VoidOne] Steam scan completed, but database insertion failed.";
        emit scanFailed("Steam scan completed but the database could not save the results.");
        return;
    }

    emit scanCompleted(games.size());
}
