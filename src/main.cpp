#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFile>
#include <QTextStream>
#include <QDateTime>

// Include های پروژه
#include "TranslationManager.h"
#include "SaveBackupManager.h"
#include "SteamScanner.h"
#include "GameModel.h"

// تابع ثبت لاگ سفارشی
void customMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    Q_UNUSED(context); // رفع هشدار unused parameter

    QFile file("debug_log.txt");
    if (file.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        QTextStream stream(&file);
        QString typeStr;
        switch (type) {
            case QtDebugMsg:    typeStr = "[DEBUG]"; break;
            case QtWarningMsg:  typeStr = "[WARNING]"; break;
            case QtCriticalMsg: typeStr = "[CRITICAL]"; break;
            case QtFatalMsg:    typeStr = "[FATAL]"; break;
        }
        stream << QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss ") 
               << typeStr << " " << msg << "\n";
    }
}

int main(int argc, char *argv[])
{
    qInstallMessageHandler(customMessageHandler);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    TranslationManager translationManager;
    SaveBackupManager saveBackupManager;
    SteamScanner steamScanner;
    GameModel gameModel;

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
        qCritical() << "Failed to load Main.qml or root objects list is empty!";
        return -1;
    }

    return app.exec();
}
