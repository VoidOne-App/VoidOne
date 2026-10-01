#include "GameModel.h"

#include <QDebug>
#include <QFileInfo>
#include <QProcess>
#include <utility>

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
        qWarning() << "[VoidOne] Refusing to add invalid executable:" << trimmedExePath;
        return false;
    }

#if defined(Q_OS_WIN)
    if (!exeInfo.fileName().endsWith(".exe", Qt::CaseInsensitive)) {
        qWarning() << "[VoidOne] Refusing non-Windows executable:" << trimmedExePath;
        return false;
    }
#else
    if (!exeInfo.isExecutable()) {
        qWarning() << "[VoidOne] Refusing non-executable file:" << trimmedExePath;
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
