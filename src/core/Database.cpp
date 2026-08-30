/****************************************************************************
**  V O I D O N E   E N G I N E — SQLite persistence layer
**  SPDX-License-Identifier: MIT
****************************************************************************/

#include "Database.h"
#include <QDir>
#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>

namespace {
constexpr auto kConnectionName = "voidone-main";
constexpr auto kDatabaseFileName = "voidone.db";
}

bool Database::initialize()
{
    if (QSqlDatabase::contains(kConnectionName)) {
        const QSqlDatabase existing = QSqlDatabase::database(kConnectionName);
        if (existing.isOpen())
            return true;
    }

    QSqlDatabase db = QSqlDatabase::contains(kConnectionName)
        ? QSqlDatabase::database(kConnectionName)
        : QSqlDatabase::addDatabase("QSQLITE", kConnectionName);

    const QString appDataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (appDataDir.isEmpty() || !QDir().mkpath(appDataDir)) {
        qCritical() << "[Database] Could not create application data directory.";
        return false;
    }

    db.setDatabaseName(QDir(appDataDir).filePath(kDatabaseFileName));
    if (!db.open()) {
        qCritical() << "[Database] SQLite open failed:" << db.lastError().text();
        return false;
    }

    QSqlQuery pragma(db);
    if (!pragma.exec("PRAGMA foreign_keys = ON"))
        qWarning() << "[Database] Could not enable foreign keys:" << pragma.lastError().text();

    QSqlQuery schema(db);
    if (!schema.exec(
            "CREATE TABLE IF NOT EXISTS games ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "name TEXT NOT NULL, "
            "exe_path TEXT UNIQUE, "
            "icon_path TEXT, "
            "platform TEXT NOT NULL DEFAULT 'Custom'"
            ")")) {
        qCritical() << "[Database] Schema creation failed:" << schema.lastError().text();
        return false;
    }

    qInfo() << "[Database] SQLite initialized:" << db.databaseName();
    return true;
}

bool Database::addGame(const GameRecord &game)
{
    if (game.name.trimmed().isEmpty()) {
        qWarning() << "[Database] Refusing to insert a game without a name.";
        return false;
    }

    QSqlDatabase db = QSqlDatabase::database(kConnectionName, false);
    if (!db.isValid() || !db.isOpen()) {
        qWarning() << "[Database] Insert requested before initialization.";
        return false;
    }

    QSqlQuery query(db);
    query.prepare(
        "INSERT INTO games (name, exe_path, icon_path, platform) "
        "VALUES (:name, :exe_path, :icon_path, :platform) "
        "ON CONFLICT(exe_path) DO UPDATE SET "
        "name=excluded.name, icon_path=excluded.icon_path, platform=excluded.platform");
    query.bindValue(":name", game.name);
    query.bindValue(":exe_path", game.exePath);
    query.bindValue(":icon_path", game.iconPath);
    query.bindValue(":platform", game.platform.isEmpty() ? QStringLiteral("Custom") : game.platform);

    if (!query.exec()) {
        qWarning() << "[Database] Insert/update failed:" << query.lastError().text();
        return false;
    }
    return true;
}

bool Database::addGamesBatch(const QVector<GameRecord> &games)
{
    if (games.isEmpty())
        return true;

    QSqlDatabase db = QSqlDatabase::database(kConnectionName, false);
    if (!db.isValid() || !db.isOpen()) {
        qWarning() << "[Database] Batch insert requested before initialization.";
        return false;
    }

    if (!db.transaction()) {
        qWarning() << "[Database] Could not start transaction:" << db.lastError().text();
        return false;
    }

    QSqlQuery query(db);
    query.prepare(
        "INSERT INTO games (name, exe_path, icon_path, platform) "
        "VALUES (:name, :exe_path, :icon_path, :platform) "
        "ON CONFLICT(exe_path) DO UPDATE SET "
        "name=excluded.name, icon_path=excluded.icon_path, platform=excluded.platform");

    for (const auto &game : games) {
        if (game.name.trimmed().isEmpty()) {
            qWarning() << "[Database] Batch contains an empty game name; rolling back.";
            db.rollback();
            return false;
        }
        query.bindValue(":name", game.name);
        query.bindValue(":exe_path", game.exePath);
        query.bindValue(":icon_path", game.iconPath);
        query.bindValue(":platform", game.platform.isEmpty() ? QStringLiteral("Custom") : game.platform);
        if (!query.exec()) {
            qWarning() << "[Database] Batch insert/update failed:" << query.lastError().text();
            db.rollback();
            return false;
        }
    }

    if (!db.commit()) {
        qWarning() << "[Database] Transaction commit failed:" << db.lastError().text();
        db.rollback();
        return false;
    }
    return true;
}

QVector<GameRecord> Database::getAllGames()
{
    QVector<GameRecord> games;
    QSqlDatabase db = QSqlDatabase::database(kConnectionName, false);
    if (!db.isValid() || !db.isOpen()) {
        qWarning() << "[Database] Read requested before initialization.";
        return games;
    }

    QSqlQuery query(db);
    if (!query.exec("SELECT id, name, exe_path, icon_path, platform FROM games ORDER BY name COLLATE NOCASE ASC")) {
        qWarning() << "[Database] Query failed:" << query.lastError().text();
        return games;
    }

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
    if (id < 0)
        return false;

    QSqlDatabase db = QSqlDatabase::database(kConnectionName, false);
    if (!db.isValid() || !db.isOpen())
        return false;

    QSqlQuery query(db);
    query.prepare("DELETE FROM games WHERE id = :id");
    query.bindValue(":id", id);
    if (!query.exec()) {
        qWarning() << "[Database] Remove failed:" << query.lastError().text();
        return false;
    }
    return query.numRowsAffected() > 0;
}
