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
        PlatformRole,
        SourceRole,
        WorkingDirRole,
        LaunchArgsRole,
        PlaySecondsRole,
        PlayCountRole,
        LastPlayedRole,
        FavoriteRole,
        HiddenRole
    };

    explicit GameModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void loadGamesFromDatabase();
    Q_INVOKABLE bool addNewGame(const QString &name, const QString &exePath, const QString &iconPath);
    Q_INVOKABLE QStringList suggestExecutables(const QString &folderPath) const;
    Q_INVOKABLE bool deleteGame(int id, int index);
    Q_INVOKABLE bool launchGame(const QString &exePath);
    Q_INVOKABLE void setFavorite(int id, bool favorite);
    Q_INVOKABLE void hideGame(int id, bool hidden);
    Q_INVOKABLE void updateLaunchOptions(int id, const QString &args, const QString &workingDir);
    Q_INVOKABLE bool updateGamePath(int id, const QString &newExecutablePath);
    Q_INVOKABLE QVariantMap getGameDetails(int id) const;
    Q_INVOKABLE void filter(const QString &searchText);
    Q_INVOKABLE void filterGames(const QString &searchText, const QString &mode);

signals:
    void countChanged();
    void gameLaunched(int id);

private:
    void rebuildVisibleGames();

    QVector<GameRecord> m_allGames;
    QVector<GameRecord> m_games;
    QString m_filterText;
    QString m_filterMode = QStringLiteral("all");
};

#endif // GAMEMODEL_H
