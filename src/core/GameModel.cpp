#include "GameModel.h"
#include <QDebug>

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
    m_games = Database::getAllGames();
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
    if (index < 0 || index >= m_games.size()) return false;
    
    if (Database::removeGame(id)) {
        beginRemoveRows(QModelIndex(), index, index);
        m_games.removeAt(index);
        endRemoveRows();
        emit countChanged();
        return true;
    }
    return false;
}

void GameModel::launchGame(const QString &exePath) {
    if (!exePath.isEmpty()) {
        QProcess::startDetached(exePath, QStringList());
    }
}
