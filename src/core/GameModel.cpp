#include "GameModel.h"

#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <QProcess>
#include <QSqlError>
#include <QSqlQuery>
#include <QVariantMap>
#include <QDateTime>
#include <QDesktopServices>
#include <QUrl>
#include <QRegularExpression>
#include <QCryptographicHash>
#include <QImage>
#include <QStandardPaths>
#ifdef Q_OS_WIN
#include <windows.h>
#include <shellapi.h>
#endif
#include <algorithm>
#include <functional>
#include <utility>
#include <cstring>

namespace {

bool isBlockedExecutable(const QFileInfo &file)
{
    const QString lower = file.completeBaseName().toLower();
    static const QStringList blocked = {
        QStringLiteral("uninstall"), QStringLiteral("setup"),
        QStringLiteral("install"), QStringLiteral("installer"),
        QStringLiteral("vcredist"), QStringLiteral("dxsetup"),
        QStringLiteral("dotnet"), QStringLiteral("crash"),
        QStringLiteral("crashhandler"), QStringLiteral("updater"),
        QStringLiteral("update"), QStringLiteral("patcher"),
        QStringLiteral("helper"), QStringLiteral("service"),
        QStringLiteral("agent"), QStringLiteral("bootstrapper")
    };

    for (const QString &token : blocked) {
        if (lower.contains(token))
            return true;
    }
    return false;
}

QString extractExecutableIcon(const QString &executablePath)
{
    const QFileInfo executable(executablePath);
    if (!executable.isFile() || executable.isSymLink())
        return {};

    const QString dataRoot = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (dataRoot.isEmpty())
        return {};

    QDir iconDirectory(QDir(dataRoot).filePath(QStringLiteral("game-icons")));
    if (!iconDirectory.exists() && !QDir().mkpath(iconDirectory.absolutePath()))
        return {};

    const QByteArray digest = QCryptographicHash::hash(
        executable.absoluteFilePath().toUtf8(), QCryptographicHash::Sha256).toHex();
    const QString iconPath = iconDirectory.filePath(QString::fromLatin1(digest) + QStringLiteral(".png"));
    if (QFileInfo::exists(iconPath))
        return iconPath;

#ifdef Q_OS_WIN
    SHFILEINFOW fileInfo{};
    const DWORD_PTR result = SHGetFileInfoW(
        reinterpret_cast<LPCWSTR>(executable.absoluteFilePath().utf16()),
        0, &fileInfo, sizeof(fileInfo), SHGFI_ICON | SHGFI_LARGEICON);
    if (result == 0 || fileInfo.hIcon == nullptr)
        return {};

    constexpr int iconSize = 96;
    BITMAPINFO bitmapInfo{};
    bitmapInfo.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
    bitmapInfo.bmiHeader.biWidth = iconSize;
    bitmapInfo.bmiHeader.biHeight = -iconSize;
    bitmapInfo.bmiHeader.biPlanes = 1;
    bitmapInfo.bmiHeader.biBitCount = 32;
    bitmapInfo.bmiHeader.biCompression = BI_RGB;

    HDC screenDc = GetDC(nullptr);
    if (screenDc == nullptr) {
        DestroyIcon(fileInfo.hIcon);
        return {};
    }

    void *pixels = nullptr;
    HBITMAP bitmap = CreateDIBSection(screenDc, &bitmapInfo, DIB_RGB_COLORS,
                                      &pixels, nullptr, 0);
    HDC memoryDc = CreateCompatibleDC(screenDc);
    if (bitmap == nullptr || memoryDc == nullptr || pixels == nullptr) {
        if (memoryDc != nullptr)
            DeleteDC(memoryDc);
        if (bitmap != nullptr)
            DeleteObject(bitmap);
        ReleaseDC(nullptr, screenDc);
        DestroyIcon(fileInfo.hIcon);
        return {};
    }

    HGDIOBJ previousObject = SelectObject(memoryDc, bitmap);
    std::memset(pixels, 0, iconSize * iconSize * 4);
    const BOOL drawn = DrawIconEx(memoryDc, 0, 0, fileInfo.hIcon,
                                  iconSize, iconSize, 0, nullptr, DI_NORMAL);
    QImage image(static_cast<uchar *>(pixels), iconSize, iconSize,
                 iconSize * 4, QImage::Format_ARGB32);
    const QImage cachedImage = image.copy();

    SelectObject(memoryDc, previousObject);
    DeleteDC(memoryDc);
    DeleteObject(bitmap);
    ReleaseDC(nullptr, screenDc);
    DestroyIcon(fileInfo.hIcon);

    if (!drawn || cachedImage.isNull() || !cachedImage.save(iconPath, "PNG"))
        return {};
    return iconPath;
#else
    Q_UNUSED(executable)
    Q_UNUSED(iconPath)
    return {};
#endif
}

} // namespace

GameModel::GameModel(QObject *parent) : QAbstractListModel(parent) {}

int GameModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_games.size();
}

QVariant GameModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_games.size())
        return {};

    const GameRecord &game = m_games.at(index.row());

    switch (role) {
    case IdRole: return game.id;
    case NameRole: return game.name;
    case ExePathRole: return game.exePath;
    case IconPathRole: return game.iconPath;
    case PlatformRole: return game.platform;
    case SourceRole: return game.source;
    case WorkingDirRole: return game.workingDir;
    case LaunchArgsRole: return game.launchArgs;
    case PlaySecondsRole: return game.playSeconds;
    case PlayCountRole: return game.playCount;
    case LastPlayedRole: return game.lastPlayed;
    case FavoriteRole: return game.favorite;
    case HiddenRole: return game.hidden;
    default: return {};
    }
}

QHash<int, QByteArray> GameModel::roleNames() const
{
    return {
        {IdRole, "id"},
        {NameRole, "name"},
        {ExePathRole, "exePath"},
        {IconPathRole, "iconPath"},
        {PlatformRole, "platform"},
        {SourceRole, "source"}, {WorkingDirRole, "workingDir"}, {LaunchArgsRole, "launchArgs"},
        {PlaySecondsRole, "playSeconds"}, {PlayCountRole, "playCount"}, {LastPlayedRole, "lastPlayed"},
        {FavoriteRole, "favorite"}, {HiddenRole, "hidden"}
    };
}

void GameModel::loadGamesFromDatabase()
{
    m_allGames = Database::getAllGames();

    // Backfill missing icons for games already present in the user's library.
    // The cache is stored in app data; the executable and database schema stay untouched.
    const QSqlDatabase db = QSqlDatabase::database(QStringLiteral("voidone-main"), false);
    for (GameRecord &game : m_allGames) {
        if (!game.iconPath.isEmpty() && QFileInfo::exists(game.iconPath))
            continue;

        const QString extractedIcon = extractExecutableIcon(game.exePath);
        if (extractedIcon.isEmpty())
            continue;

        game.iconPath = extractedIcon;
        if (db.isValid() && db.isOpen()) {
            QSqlQuery update(db);
            update.prepare("UPDATE games SET icon_path = :icon WHERE id = :id");
            update.bindValue(":icon", extractedIcon);
            update.bindValue(":id", game.id);
            if (!update.exec())
                qWarning() << "[VoidOne] Could not persist cached game icon:" << update.lastError().text();
        }
    }

    rebuildVisibleGames();
}

bool GameModel::addNewGame(const QString &name, const QString &exePath, const QString &iconPath)
{
    const QString trimmedName = name.trimmed();
    const QString trimmedExePath = exePath.trimmed();
    if (trimmedName.isEmpty() || trimmedExePath.isEmpty()) {
        qWarning() << "[VoidOne] Refusing to add game with an empty name or executable path.";
        return false;
    }

    const QFileInfo exeInfo(trimmedExePath);
    if (!exeInfo.isFile() || exeInfo.isSymLink()) {
        qWarning() << "[VoidOne] Refusing invalid game executable:" << trimmedExePath;
        return false;
    }

#if defined(Q_OS_WIN)
    if (!exeInfo.fileName().endsWith(".exe", Qt::CaseInsensitive)) {
        qWarning() << "[VoidOne] Refusing non-Windows executable:" << trimmedExePath;
        return false;
    }
#else
    if (!exeInfo.isExecutable()) {
        qWarning() << "[VoidOne] Refusing non-executable target:" << trimmedExePath;
        return false;
    }
#endif

    GameRecord game;
    game.name = trimmedName;
    game.exePath = exeInfo.absoluteFilePath();
    game.iconPath = iconPath.trimmed();
    if (game.iconPath.isEmpty() || !QFileInfo::exists(game.iconPath))
        game.iconPath = extractExecutableIcon(game.exePath);
    game.platform = QStringLiteral("Custom");
    game.source = QStringLiteral("Local");
    game.workingDir = exeInfo.absolutePath();
    if (!Database::addGame(game))
        return false;

    loadGamesFromDatabase();
    return true;
}

QStringList GameModel::suggestExecutables(const QString &folderPath) const
{
    const QString cleanPath = folderPath.trimmed();
    if (cleanPath.isEmpty())
        return {};

    const QDir root(cleanPath);
    if (!root.exists())
        return {};

    struct Candidate {
        int score = 0;
        qint64 size = 0;
        QString path;
    };

    QList<Candidate> candidates;
    const QString folderName = root.dirName().toLower();

#if defined(Q_OS_WIN)
    const QStringList filters = {QStringLiteral("*.exe")};
    const QDir::Filters fileFilters = QDir::Files | QDir::NoDotAndDotDot | QDir::NoSymLinks;
#else
    const QStringList filters = {QStringLiteral("*")};
    const QDir::Filters fileFilters = QDir::Files | QDir::Executable |
                                      QDir::NoDotAndDotDot | QDir::NoSymLinks;
#endif

    std::function<void(const QDir &, int)> scan =
        [&](const QDir &dir, int depth) {
            const QFileInfoList files = dir.entryInfoList(filters, fileFilters, QDir::Name);
            for (const QFileInfo &file : files) {
                if (isBlockedExecutable(file))
                    continue;

#if !defined(Q_OS_WIN)
                if (!file.isExecutable())
                    continue;
#endif

                const QString stem = file.completeBaseName().toLower();
                int score = 0;

                if (depth == 0)
                    score += 30;
                else if (depth == 1)
                    score += 18;
                else
                    score += 8;

                if (stem == folderName)
                    score += 80;
                else if (!folderName.isEmpty() && stem.contains(folderName))
                    score += 30;

                // Prefer substantial binaries over tiny helper programs.
                if (file.size() > 50 * 1024 * 1024)
                    score += 20;
                else if (file.size() > 10 * 1024 * 1024)
                    score += 10;

                candidates.append({score, file.size(), file.absoluteFilePath()});
            }

            if (depth >= 2)
                return;

            const QFileInfoList dirs = dir.entryInfoList(
                QDir::Dirs | QDir::NoDotAndDotDot | QDir::NoSymLinks, QDir::Name);

            for (const QFileInfo &child : dirs)
                scan(QDir(child.absoluteFilePath()), depth + 1);
        };

    scan(root, 0);

    std::sort(candidates.begin(), candidates.end(), [](const Candidate &a, const Candidate &b) {
        if (a.score != b.score)
            return a.score > b.score;
        if (a.size != b.size)
            return a.size > b.size;
        return a.path < b.path;
    });

    QStringList result;
    for (const Candidate &candidate : std::as_const(candidates)) {
        if (!result.contains(candidate.path))
            result.append(candidate.path);
        if (result.size() >= 12)
            break;
    }

    return result;
}

bool GameModel::deleteGame(int id, int index)
{
    if (index < 0 || index >= m_games.size() || m_games.at(index).id != id)
        return false;

    if (!Database::removeGame(id))
        return false;

    loadGamesFromDatabase();
    return true;
}

bool GameModel::launchGame(const QString &exePath)
{
    const QString trimmedPath = exePath.trimmed();
    if (trimmedPath.isEmpty()) {
        qWarning() << "[VoidOne] Refusing to launch an empty game path.";
        return false;
    }

    const QFileInfo targetInfo(trimmedPath);
    if (!targetInfo.isFile() || targetInfo.isSymLink()) {
        qWarning() << "[VoidOne] Refusing to launch non-file or symlink:" << trimmedPath;
        return false;
    }

#if defined(Q_OS_WIN)
    if (!targetInfo.fileName().endsWith(".exe", Qt::CaseInsensitive)) {
        qWarning() << "[VoidOne] Refusing non-executable Windows target:" << trimmedPath;
        return false;
    }
#else
    if (!targetInfo.isExecutable()) {
        qWarning() << "[VoidOne] Refusing non-executable target:" << trimmedPath;
        return false;
    }
#endif

    const QString absolutePath = targetInfo.absoluteFilePath();
    QString workingDirectory = targetInfo.absolutePath();
    QStringList arguments;
    QSqlQuery options(QSqlDatabase::database(QStringLiteral("voidone-main"), false));
    options.prepare("SELECT launch_args, working_dir FROM games WHERE exe_path = :path");
    options.bindValue(":path", absolutePath);
    if (options.exec() && options.next()) {
        const QString savedArgs = options.value(0).toString();
        const QString savedDir = options.value(1).toString();
        if (!savedDir.trimmed().isEmpty() && QDir(savedDir).exists())
            workingDirectory = savedDir;
        if (!savedArgs.trimmed().isEmpty())
            arguments = QProcess::splitCommand(savedArgs);
    }

    int launchedId = -1;
    int steamAppId = 0;
    QString gameSource;
    for (const auto &game : std::as_const(m_allGames)) {
        if (QFileInfo(game.exePath).absoluteFilePath() == absolutePath) {
            launchedId = game.id;
            steamAppId = game.steamAppId;
            gameSource = game.source;
            break;
        }
    }

    qint64 pid = -1;
    bool launchAccepted = false;
    if (steamAppId > 0 && gameSource.compare(QStringLiteral("Steam"), Qt::CaseInsensitive) == 0) {
        const QUrl steamUrl(QStringLiteral("steam://rungameid/%1").arg(steamAppId));
        launchAccepted = QDesktopServices::openUrl(steamUrl);
        if (!launchAccepted)
            qWarning() << "[VoidOne] Steam protocol launch failed; trying executable directly:" << steamUrl;
    }
    if (!launchAccepted)
        launchAccepted = QProcess::startDetached(absolutePath, arguments, workingDirectory, &pid);
    if (!launchAccepted) {
        qWarning() << "[VoidOne] Failed to launch game:" << absolutePath;
        return false;
    }

    QSqlQuery stats(QSqlDatabase::database(QStringLiteral("voidone-main"), false));
    stats.prepare("UPDATE games SET play_count = play_count + 1, last_played = :now WHERE exe_path = :path");
    stats.bindValue(":now", QDateTime::currentSecsSinceEpoch());
    stats.bindValue(":path", absolutePath);
    stats.exec();
    loadGamesFromDatabase();
    emit gameLaunched(launchedId);
    qInfo() << "[VoidOne] Game launched:" << absolutePath << "PID:" << pid;
    return true;
}

void GameModel::filter(const QString &searchText)
{
    m_filterText = searchText.trimmed();
    rebuildVisibleGames();
}

void GameModel::filterGames(const QString &searchText, const QString &mode)
{
    const QStringList supportedModes = {
        QStringLiteral("all"), QStringLiteral("favorites"), QStringLiteral("recent")
    };
    m_filterMode = supportedModes.contains(mode) ? mode : QStringLiteral("all");
    m_filterText = searchText.trimmed();
    rebuildVisibleGames();
}

void GameModel::rebuildVisibleGames()
{
    beginResetModel();
    m_games.clear();

    for (const auto &game : std::as_const(m_allGames)) {
        if (game.hidden)
            continue;
        if (m_filterMode == QStringLiteral("favorites") && !game.favorite)
            continue;
        if (m_filterMode == QStringLiteral("recent") && game.lastPlayed <= 0)
            continue;
        if (!m_filterText.isEmpty()
            && !game.name.contains(m_filterText, Qt::CaseInsensitive)
            && !game.platform.contains(m_filterText, Qt::CaseInsensitive)
            && !game.exePath.contains(m_filterText, Qt::CaseInsensitive)
            && !game.source.contains(m_filterText, Qt::CaseInsensitive)) {
            continue;
        }
        m_games.append(game);
    }

    if (m_filterMode == QStringLiteral("recent")) {
        std::stable_sort(m_games.begin(), m_games.end(),
                         [](const GameRecord &left, const GameRecord &right) {
            return left.lastPlayed > right.lastPlayed;
        });
    } else if (m_filterMode == QStringLiteral("favorites")) {
        std::stable_sort(m_games.begin(), m_games.end(),
                         [](const GameRecord &left, const GameRecord &right) {
            return left.name.compare(right.name, Qt::CaseInsensitive) < 0;
        });
    }

    endResetModel();
    emit countChanged();
}

void GameModel::setFavorite(int id, bool favorite)
{
    const QSqlDatabase db = QSqlDatabase::database(QStringLiteral("voidone-main"), false);
    if (!db.isValid() || !db.isOpen()) {
        qWarning() << "[VoidOne] Favorite update requested while the database is unavailable.";
        return;
    }

    QSqlQuery query(db);
    query.prepare("UPDATE games SET favorite = :favorite WHERE id = :id");
    query.bindValue(":favorite", favorite ? 1 : 0);
    query.bindValue(":id", id);
    if (!query.exec()) {
        qWarning() << "[VoidOne] Favorite update failed:" << query.lastError().text();
        return;
    }
    if (query.numRowsAffected() == 0) {
        qWarning() << "[VoidOne] Favorite update matched no game row for id:" << id;
        return;
    }

    for (GameRecord &game : m_allGames) {
        if (game.id == id) {
            game.favorite = favorite;
            break;
        }
    }

    // Update the visible role in place instead of resetting the whole model.
    // This keeps the clicked card stable and avoids losing its interaction mid-click.
    if (m_filterMode == QStringLiteral("favorites") && !favorite) {
        rebuildVisibleGames();
        return;
    }

    for (int row = 0; row < m_games.size(); ++row) {
        if (m_games[row].id == id) {
            m_games[row].favorite = favorite;
            emit dataChanged(index(row, 0), index(row, 0), {FavoriteRole});
            return;
        }
    }
}
void GameModel::hideGame(int id, bool hidden)
{
    QSqlQuery q(QSqlDatabase::database(QStringLiteral("voidone-main"), false));
    q.prepare("UPDATE games SET hidden=:hidden WHERE id=:id");
    q.bindValue(":hidden", hidden ? 1 : 0); q.bindValue(":id", id);
    if (q.exec()) loadGamesFromDatabase();
}

bool GameModel::updateGamePath(int id, const QString &newExecutablePath)
{
    const QString path = newExecutablePath.trimmed();
    const QFileInfo info(path);
    if (!info.isFile() || info.isSymLink()) {
        qWarning() << "[VoidOne] Refusing invalid replacement executable:" << path;
        return false;
    }
#if defined(Q_OS_WIN)
    if (!info.fileName().endsWith(QStringLiteral(".exe"), Qt::CaseInsensitive))
        return false;
#else
    if (!info.isExecutable())
        return false;
#endif
    const QString absolutePath = info.absoluteFilePath();
    const QSqlDatabase db = QSqlDatabase::database(QStringLiteral("voidone-main"), false);
    if (!db.isValid() || !db.isOpen())
        return false;
    QSqlQuery query(db);
    query.prepare("UPDATE games SET exe_path = :path, working_dir = :dir, icon_path = '' WHERE id = :id");
    query.bindValue(":path", absolutePath);
    query.bindValue(":dir", info.absolutePath());
    query.bindValue(":id", id);
    if (!query.exec() || query.numRowsAffected() == 0) {
        qWarning() << "[VoidOne] Failed to update game executable path:" << query.lastError().text();
        return false;
    }
    loadGamesFromDatabase();
    return true;
}
void GameModel::updateLaunchOptions(int id, const QString &args, const QString &workingDir)
{
    const QSqlDatabase db = QSqlDatabase::database(QStringLiteral("voidone-main"), false);
    if (!db.isValid() || !db.isOpen()) {
        qWarning() << "[VoidOne] Cannot update launch options: database is unavailable.";
        return;
    }
    QSqlQuery q(db);
    q.prepare("UPDATE games SET launch_args=:args, working_dir=:dir WHERE id=:id");
    q.bindValue(":args", args); q.bindValue(":dir", workingDir); q.bindValue(":id", id);
    if (!q.exec()) {
        qWarning() << "[VoidOne] Failed to update launch options:" << q.lastError().text();
        return;
    }
    loadGamesFromDatabase();
}

QVariantMap GameModel::getGameDetails(int id) const
{
    QVariantMap r;
    for (const GameRecord &g : m_allGames) if (g.id == id) {
        r["id"]=g.id; r["name"]=g.name; r["exePath"]=g.exePath; r["iconPath"]=g.iconPath;
        r["platform"]=g.platform; r["source"]=g.source; r["workingDir"]=g.workingDir;
        r["launchArgs"]=g.launchArgs; r["playSeconds"]=g.playSeconds; r["playCount"]=g.playCount;
        r["lastPlayed"]=g.lastPlayed; r["favorite"]=g.favorite; r["hidden"]=g.hidden; break;
    }
    return r;
}
