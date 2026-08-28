/****************************************************************************
** 
**  V O I D O N E   E N G I N E
**  High-Performance QML & C++ Core
** 
**  Copyright (C) 2026 VoidOne-App
**  Repository: https://github.com/VoidOne-App/VoidOne
**  SPDX-License-Identifier: MIT
** 
****************************************************************************/

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
    
    if (!QDir().mkpath(appDataDir)) {
        qCritical() << "[VoidOne] Database Error: Could not create AppData directory.";
        return false;
    }

    // استفاده از نام ثابت voidone.db برای حفظ دیتای کاربر در آپدیت‌های بعدی
    db.setDatabaseName(appDataDir + "/voidone.db");

    if (!db.open()) {
        qCritical() << "[VoidOne] Database Error: Connection failed -" << db.lastError().text();
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
        qCritical() << "[VoidOne] Database Error: Failed to create table -" << query.lastError().text();
        return false;
    }

    qDebug() << "[VoidOne] Database initialized successfully at:" << appDataDir + "/voidone.db";
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
        qWarning() << "[VoidOne] Database Warning: Insert game failed -" << query.lastError().text();
        return false;
    }
    return true;
}

bool Database::addGamesBatch(const QVector<GameRecord>& games)
{
    if (games.isEmpty()) {
        return true;
    }

    QSqlDatabase db = QSqlDatabase::database();
    if (!db.isOpen()) {
        qWarning() << "[VoidOne] Database Warning: Batch insert requested before database was opened.";
        return false;
    }

    if (!db.transaction()) {
        qWarning() << "[VoidOne] Database Warning: Could not start batch transaction -" << db.lastError().text();
        return false;
    }

    QSqlQuery query;
    query.prepare("INSERT OR REPLACE INTO games (name, exe_path, icon_path, platform) "
                  "VALUES (:name, :exe_path, :icon_path, :platform)");

    for (const auto& game : games) {
        query.bindValue(":name", game.name);
        query.bindValue(":exe_path", game.exePath);
        query.bindValue(":icon_path", game.iconPath);
        query.bindValue(":platform", game.platform.isEmpty() ? "Custom" : game.platform);

        if (!query.exec()) {
            qWarning() << "[VoidOne] Database Warning: Batch insert failed -" << query.lastError().text();
            db.rollback();
            return false;
        }
    }

    if (!db.commit()) {
        qWarning() << "[VoidOne] Database Warning: Batch insert failed to commit -" << db.lastError().text();
        return false;
    }

    qDebug() << "[VoidOne] Database: Batch inserted" << games.size() << "games.";
    return true;
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
    
    if (!query.exec()) {
        qWarning() << "[VoidOne] Database Warning: Remove game failed -" << query.lastError().text();
        return false;
    }
    return true;
}
