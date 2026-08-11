#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QDebug>

#include "core/Database.h"
#include "core/SteamScanner.h"
#include "core/GameModel.h"
#include "core/TranslationManager.h"
#include "core/SaveBackupManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setOrganizationName("NeonStudio");
    app.setApplicationName("NeonLauncher");
    app.setApplicationVersion("1.0.2");

    // ۱. مقداردهی پایگاه داده پیشرفته
    if (!Database::initialize()) {
        qCritical() << "Fatal: Could not initialize local SQLite database.";
        return -1;
    }

    // ۲. تعریف متغیرها و کامپوننت‌های اصلی
    GameModel gameModel;
    SteamScanner steamScanner;
    TranslationManager translationManager;
    SaveBackupManager saveBackupManager;

    // بارگذاری داده‌ها
    gameModel.loadGamesFromDatabase();

    // اتصال اسکنر استیم به مدل جهت به‌روزرسانی خودکار
    QObject::connect(&steamScanner, &SteamScanner::scanCompleted, [&gameModel](int count) {
        qDebug() << "Steam Async Scan Completed. Found:" << count;
        gameModel.loadGamesFromDatabase();
    });

    QQmlApplicationEngine engine;

    // ۳. اکسپوز مستقیم کامپوننت‌ها به محیط QML
    engine.rootContext()->setContextProperty("gameModel", &gameModel);
    engine.rootContext()->setContextProperty("steamScanner", &steamScanner);
    engine.rootContext()->setContextProperty("trManager", &translationManager);
    engine.rootContext()->setContextProperty("saveBackupManager", &saveBackupManager);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);

    engine.loadFromModule("NeonLauncher", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}

    // Expose objects to QML (۴. معرفی به محیط QML)
    engine.rootContext()->setContextProperty("gameModel", &gameModel);
    engine.rootContext()->setContextProperty("trManager", &translationManager);
    engine.rootContext()->setContextProperty("saveBackupManager", &saveBackupManager);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);

    engine.loadFromModule("NeonLauncher", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
