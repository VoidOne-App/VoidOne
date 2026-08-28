#ifndef GAMEMODEL_H
#define GAMEMODEL_H

#include <QAbstractListModel>
#include <QProcess>
#include "Database.h"

class GameModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum GameRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        ExePathRole,
        IconPathRole,
        PlatformRole
    };

    explicit GameModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void loadGamesFromDatabase();
    Q_INVOKABLE bool addNewGame(const QString &name, const QString &exePath, const QString &iconPath);
    Q_INVOKABLE bool deleteGame(int id, int index);
    Q_INVOKABLE void launchGame(const QString &exePath);
    Q_INVOKABLE void filter(const QString &searchText);

signals:
    void countChanged();

private:
    QVector<GameRecord> m_allGames;
    QVector<GameRecord> m_games;
};

#endif // GAMEMODEL_H
