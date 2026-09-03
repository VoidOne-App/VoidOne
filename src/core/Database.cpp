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

bool hasOpenDatabase()
{
    if (!QSqlDatabase::contains(kConnectionName))
        return false;

    const QSqlDatabase db = QSqlDatabase::database(kConnectionName, false);
    return db.isValid() && db.isOpen();
}

QSqlDatabase database()
{
    return QSqlDatabase::database(kConnectionName, false);
}

void discardConnection()
{
    if (!QSqlDatabase::contains(kConnectionName))
        return;

    {
        QSqlDatabase db = QSqlDatabase::database(kConnectionName, false);
        if (db.isValid())
            db.close();
    }

    QSqlDatabase::removeDatabase(kConnectionName);
}

bool prepareSchema(const QSqlDatabase &db)
{
    QSqlQuery pragma(db);
    if (!pragma.exec("PRAGMA foreign_keys = ON")) {
        qWarning() << "[Database] Could not enable foreign keys:" << pragma.lastError().text();
        return false;
    }

    QSqlQuery journal(db);
    if (!journal.exec("PRAGMA journal_mode = WAL")) {
        qWarning() << "[Database] Could not enable WAL mode:" << journal.lastError().text();
        // WAL is an optimization, not a correctness requirement.
    }

    QSqlQuery busyTimeout(db);
    if (!busyTimeout.exec("PRAGMA busy_timeout = 5000")) {
        qWarning() << "[Database] Could not set SQLite busy timeout:" << busyTimeout.lastError().text();
    }

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

    return true;
}
}

bool Database::initialize()
{
    if (!QSqlDatabase::isDriverAvailable(QStringLiteral("QSQLITE"))) {
        qCritical() << "[Database] QSQLITE driver is unavailable. Available drivers:"
                    << QSqlDatabase::drivers();
        return false;
    }

    if (hasOpenDatabase())
        return true;

    discardConnection();

    const QString appDataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (appDataDir.isEmpty() || !QDir().mkpath(appDataDir)) {
        qCritical() << "[Database] Could not create application data directory.";
        return false;
    }

    QSqlDatabase db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), kConnectionName);
    db.setDatabaseName(QDir(appDataDir).filePath(kDatabaseFileName));

    if (!db.open()) {
        qCritical() << "[Database] SQLite open failed:" << db.lastError().text();
        db.close();
        db = QSqlDatabase();
        discardConnection();
        return false;
    }

    if (!prepareSchema(db)) {
        db.close();
        db = QSqlDatabase();
        discardConnection();
        return false;
    }

    qInfo() << "[Database] SQLite initialized:" << db.databaseName();
    return true;
}

void Database::shutdown()
{
    discardConnection();
}

bool Database::addGame(const GameRecord &game)
{
    if (game.name.trimmed().isEmpty()) {
        qWarning() << "[Database] Refusing to insert a game without a name.";
        return false;
    }

    if (game.exePath.trimmed().isEmpty()) {
        qWarning() << "[Database] Refusing to insert a game without an executable path.";
        return false;
    }

    const QSqlDatabase db = database();
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
    query.bindValue(":name", game.name.trimmed());
    query.bindValue(":exe_path", game.exePath.trimmed());
    query.bindValue(":icon_path", game.iconPath.trimmed());
    query.bindValue(":platform", game.platform.trimmed().isEmpty() ? QStringLiteral("Custom") : game.platform.trimmed());

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

    const QSqlDatabase db = database();
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
        if (game.name.trimmed().isEmpty() || game.exePath.trimmed().isEmpty()) {
            qWarning() << "[Database] Batch contains an invalid game; rolling back.";
            db.rollback();
            return false;
        }

        query.bindValue(":name", game.name.trimmed());
        query.bindValue(":exe_path", game.exePath.trimmed());
        query.bindValue(":icon_path", game.iconPath.trimmed());
        query.bindValue(":platform", game.platform.trimmed().isEmpty() ? QStringLiteral("Custom") : game.platform.trimmed());
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
    const QSqlDatabase db = database();
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
    if (id <= 0)
        return false;

    const QSqlDatabase db = database();
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
