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

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>

// ماژول‌های بک‌اند (++C)
#include "Database.h"
#include "GameModel.h"
#include "SaveBackupManager.h"
#include "SteamScanner.h"
#include "TranslationManager.h"

int main(int argc, char *argv[])
{
    // ۱. تنظیمات پایه‌ای اپلیکیشن (یکپارچه با برند VoidOne)
    QCoreApplication::setOrganizationName("VoidOne-App");
    QCoreApplication::setOrganizationDomain("voidone.app");
    QCoreApplication::setApplicationName("VoidOne"); 
    
    // تنظیم نسخه به حالت آلفا (V0.0.1 A)
    QCoreApplication::setApplicationVersion("V0.0.1 A"); 

    QGuiApplication app(argc, argv);

    // لاگ‌های ترمینالی خفن برای دیباگ
    qDebug() << "\n[VoidOne] =========================================";
    qDebug() << "[VoidOne] Boot sequence initiated... Version:" << QCoreApplication::applicationVersion();

    // ۲. راه‌اندازی دیتابیس در خط مقدم (اگر بالا نیاد، برنامه کرش مدیریت‌شده میده)
    if (!Database::initialize()) {
        qCritical() << "[VoidOne] FATAL: Failed to initialize the SQLite database.";
        return -1; 
    }
    qDebug() << "[VoidOne] SQLite Database mounted successfully.";

    // ۳. ساخت نمونه (Instance) از سیستم‌های بک‌اند و لود دیتای اولیه
    GameModel gameModel;
    gameModel.loadGamesFromDatabase(); // بارگذاری لیست بازی‌ها از دیتابیس

    SaveBackupManager saveBackupManager;
    SteamScanner steamScanner;
    TranslationManager trManager;
    
    qDebug() << "[VoidOne] Backend controllers instantiated.";

    // ۴. راه‌اندازی موتور QML
    QQmlApplicationEngine engine;

    // ۵. تزریق کلاس‌های ++C به موتور QML (دقیقاً با نام‌های استفاده شده در UI)
    QQmlContext* context = engine.rootContext();
    context->setContextProperty("gameModel", &gameModel);
    context->setContextProperty("saveBackupManager", &saveBackupManager);
    context->setContextProperty("steamScanner", &steamScanner);
    context->setContextProperty("trManager", &trManager);

    qDebug() << "[VoidOne] Context properties injected into QML.";

    // ۶. اتصال سیگنال‌های ایمنی برای جلوگیری از کرش‌های بی‌صدا
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() {
            qCritical() << "[VoidOne] FATAL: Failed to create root QML objects.";
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection
    );

    // ۷. بارگذاری ماژول اصلی رابط کاربری
    qDebug() << "[VoidOne] Loading primary QML module (Main.qml)...";
    engine.loadFromModule("VoidOne", "Main");

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "[VoidOne] FATAL: QML Engine is empty after load.";
        return -1;
    }

    qDebug() << "[VoidOne] UI rendered successfully. Entering Event Loop.";
    qDebug() << "[VoidOne] =========================================\n";

    return app.exec();
}
