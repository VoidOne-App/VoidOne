#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

// Include های مربوط به برنامه‌تان
#include "TranslationManager.h"
#include "SaveBackupManager.h"
#include "SteamScanner.h"
#include "GameModel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // تعریف ساختارهای Backend
    TranslationManager translationManager;
    SaveBackupManager saveBackupManager;
    SteamScanner steamScanner;
    GameModel gameModel;

    // تزریق context property‌ها به QML
    engine.rootContext()->setContextProperty("trManager", &translationManager);
    engine.rootContext()->setContextProperty("saveBackupManager", &saveBackupManager);
    engine.rootContext()->setContextProperty("steamScanner", &steamScanner);
    engine.rootContext()->setContextProperty("gameModel", &gameModel);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection
    );

    engine.loadFromModule("NeonLauncher", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
