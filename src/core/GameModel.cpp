#include "GameModel.h"
#include <QDebug>
#include <QFileInfo>
#include <utility>

GameModel::GameModel(QObject *parent) : QAbstractListModel(parent) {}

int GameModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid()) return 0;
    return m_games.size();
}

QVariant GameModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_games.size())
        return QVariant();

    const GameRecord &game = m_games.at(index.row());

    switch (role) {
    case IdRole: return game.id;
    case NameRole: return game.name;
    case ExePathRole: return game.exePath;
    case IconPathRole: return game.iconPath;
    case PlatformRole: return game.platform;
    default: return QVariant();
    }
}

QHash<int, QByteArray> GameModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[NameRole] = "name";
    roles[ExePathRole] = "exePath";
    roles[IconPathRole] = "iconPath";
    roles[PlatformRole] = "platform";
    return roles;
}

void GameModel::loadGamesFromDatabase() {
    beginResetModel();
    m_allGames = Database::getAllGames();
    m_games = m_allGames;
    endResetModel();
    emit countChanged();
}

bool GameModel::addNewGame(const QString &name, const QString &exePath, const QString &iconPath) {
    GameRecord game{-1, name, exePath, iconPath, "Custom"};
    if (Database::addGame(game)) {
        loadGamesFromDatabase();
        return true;
    }
    return false;
}

bool GameModel::deleteGame(int id, int index) {
    if (index < 0 || index >= m_games.size() || m_games.at(index).id != id) {
        return false;
    }

    if (Database::removeGame(id)) {
        loadGamesFromDatabase();
        return true;
    }
    return false;
}

void GameModel::launchGame(const QString &exePath) {
    if (exePath.isEmpty()) {
        return;
    }

    const QFileInfo targetInfo(exePath);
    const QString workingDirectory = targetInfo.isDir()
        ? targetInfo.absoluteFilePath()
        : targetInfo.absolutePath();

    QString program = exePath;
    QStringList arguments;

    if (targetInfo.isDir()) {
#if defined(Q_OS_WIN)
        qWarning() << "[VoidOne] Cannot launch a directory on Windows:" << exePath;
        return;
#else
        program = QStringLiteral("xdg-open");
        arguments << exePath;
#endif
    }

    if (!QProcess::startDetached(program, arguments, workingDirectory)) {
        qWarning() << "[VoidOne] Failed to launch game path:" << exePath;
    }
}

void GameModel::filter(const QString &searchText) {
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
