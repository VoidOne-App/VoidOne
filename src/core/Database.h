#ifndef DATABASE_H
#define DATABASE_H

#include <QMetaType>
#include <QSqlDatabase>
#include <QString>
#include <QVector>

struct GameRecord {
    int id = -1;
    QString name;
    QString exePath;
    QString iconPath;
    QString platform;
};

Q_DECLARE_METATYPE(GameRecord)
Q_DECLARE_METATYPE(QVector<GameRecord>)

class Database
{
public:
    static bool initialize();
    static void shutdown();
    static bool addGame(const GameRecord &game);
    static bool addGamesBatch(const QVector<GameRecord> &games);
    static QVector<GameRecord> getAllGames();
    static bool removeGame(int id);
};

#endif // DATABASE_H
