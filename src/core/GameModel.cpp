#include "GameModel.h"

#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <QProcess>
#include <QRegularExpression>
#include <algorithm>
#include <utility>

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
        {PlatformRole, "platform"}
    };
}

void GameModel::loadGamesFromDatabase()
{
    beginResetModel();
    m_allGames = Database::getAllGames();
    m_games = m_allGames;
    endResetModel();
    emit countChanged();
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

    GameRecord game{-1, trimmedName, exeInfo.absoluteFilePath(),
                    iconPath.trimmed(), QStringLiteral("Custom")};
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

void GameModel::launchGame(const QString &exePath)
{
    const QString trimmedPath = exePath.trimmed();
    if (trimmedPath.isEmpty()) {
        qWarning() << "[VoidOne] Refusing to launch an empty game path.";
        return;
    }

    const QFileInfo targetInfo(trimmedPath);
    if (!targetInfo.isFile() || targetInfo.isSymLink()) {
        qWarning() << "[VoidOne] Refusing to launch non-file or symlink:" << trimmedPath;
        return;
    }

#if defined(Q_OS_WIN)
    if (!targetInfo.fileName().endsWith(".exe", Qt::CaseInsensitive)) {
        qWarning() << "[VoidOne] Refusing non-executable Windows target:" << trimmedPath;
        return;
    }
#else
    if (!targetInfo.isExecutable()) {
        qWarning() << "[VoidOne] Refusing non-executable target:" << trimmedPath;
        return;
    }
#endif

    const QString absolutePath = targetInfo.absoluteFilePath();
    const QString workingDirectory = targetInfo.absolutePath();

    qint64 pid = -1;
    if (!QProcess::startDetached(absolutePath, {}, workingDirectory, &pid)) {
        qWarning() << "[VoidOne] Failed to launch game:" << absolutePath;
        return;
    }

    qInfo() << "[VoidOne] Game launched:" << absolutePath << "PID:" << pid;
}

void GameModel::filter(const QString &searchText)
{
    const QString needle = searchText.trimmed();

    beginResetModel();
    if (needle.isEmpty()) {
        m_games = m_allGames;
    } else {
        m_games.clear();
        for (const auto &game : std::as_const(m_allGames)) {
            if (game.name.contains(needle, Qt::CaseInsensitive)
                || game.platform.contains(needle, Qt::CaseInsensitive)
                || game.exePath.contains(needle, Qt::CaseInsensitive)) {
                m_games.append(game);
            }
        }
    }
    endResetModel();
    emit countChanged();
}
