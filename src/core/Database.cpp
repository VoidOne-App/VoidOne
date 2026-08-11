#include "Database.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

bool Database::initialize()
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    QString appDataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(appDataDir);
    db.setDatabaseName(appDataDir + "/neon_launcher_v2.db");

    if (!db.open()) {
        qCritical() << "Database connection failed:" << db.lastError().text();
        return false;
    }

    QSqlQuery query;
    bool success = query.exec(
        "CREATE TABLE IF NOT EXISTS games ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "name TEXT NOT NULL, "
        "exe_path TEXT UNIQUE, "
        "icon_path TEXT, "
        "platform TEXT DEFAULT 'Custom'"
        ")"
    );

    if (!success) {
        qCritical() << "Failed to create table:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::addGame(const GameRecord& game)
{
    QSqlQuery query;
    query.prepare("INSERT OR REPLACE INTO games (name, exe_path, icon_path, platform) "
                  "VALUES (:name, :exe_path, :icon_path, :platform)");
    query.bindValue(":name", game.name);
    query.bindValue(":exe_path", game.exePath);
    query.bindValue(":icon_path", game.iconPath);
    query.bindValue(":platform", game.platform.isEmpty() ? "Custom" : game.platform);

    if (!query.exec()) {
        qWarning() << "Insert game failed:" << query.lastError().text();
        return false;
    }
    return true;
}

bool Database::addGamesBatch(const QVector<GameRecord>& games)
{
    QSqlDatabase db = QSqlDatabase::database();
    db.transaction();
    
    QSqlQuery query;
    query.prepare("INSERT OR REPLACE INTO games (name, exe_path, icon_path, platform) "
                  "VALUES (:name, :exe_path, :icon_path, :platform)");

    for (const auto& game : games) {
        query.bindValue(":name", game.name);
        query.bindValue(":exe_path", game.exePath);
        query.bindValue(":icon_path", game.iconPath);
        query.bindValue(":platform", game.platform);
        query.exec();
    }

    return db.commit();
}

QVector<GameRecord> Database::getAllGames()
{
    QVector<GameRecord> games;
    QSqlQuery query("SELECT id, name, exe_path, icon_path, platform FROM games ORDER BY name ASC");

    while (query.next()) {
        GameRecord rec;
        rec.id = query.value(0).toInt();
        rec.name = query.value(1).toString();
        rec.exePath = query.value(2).toString();
        rec.iconPath = query.value(3).toString();
        rec.platform = query.value(4).toString();
        games.append(rec);
    }
    return games;
}

bool Database::removeGame(int id)
{
    QSqlQuery query;
    query.prepare("DELETE FROM games WHERE id = :id");
    query.bindValue(":id", id);
    return query.exec();
}
