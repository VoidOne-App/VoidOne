#ifndef DATABASE_H
#define DATABASE_H

#include <QString>
#include <QVariantList>
#include <QSqlDatabase>

struct GameRecord {
    int id = -1;
    QString name;
    QString exePath;
    QString iconPath;
    QString platform;
};

class Database
{
public:
    static bool initialize();
    static bool addGame(const GameRecord& game);
    static bool addGamesBatch(const QVector<GameRecord>& games);
    static QVector<GameRecord> getAllGames();
    static bool removeGame(int id);
};

#endif // DATABASE_H
