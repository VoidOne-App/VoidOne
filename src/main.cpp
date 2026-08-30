/****************************************************************************
**  V O I D O N E   E N G I N E  [ENTERPRISE CORE]
**  Copyright (C) 2026 VoidOne_app
**  SPDX-License-Identifier: MIT
****************************************************************************/

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCommandLineParser>
#include <QStandardPaths>
#include <QLockFile>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QSysInfo>
#include <QMutex>
#include <QThread>
#include <QDebug>

#include <exception>
#include <csignal>
#include <cstdlib>

#include "VoidOneVersion.h"
#include "Database.h"
#include "GameModel.h"
#include "SaveBackupManager.h"
#include "SteamScanner.h"
#include "TranslationManager.h"

namespace {

QMutex g_logMutex;
QFile g_logFile;

QString logDirectoryPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/logs";
}

void enterpriseMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message)
{
    Q_UNUSED(context)
    QMutexLocker locker(&g_logMutex);

    const char *levelTag = "INFO ";
    switch (type) {
        case QtDebugMsg:    levelTag = "DEBUG"; break;
        case QtInfoMsg:     levelTag = "INFO "; break;
        case QtWarningMsg:  levelTag = "WARN "; break;
        case QtCriticalMsg: levelTag = "CRIT "; break;
        case QtFatalMsg:    levelTag = "FATAL"; break;
    }

    const QString line = QStringLiteral("[%1] [%2] [TID %3] %4")
        .arg(QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss.zzz"))
        .arg(levelTag)
        .arg(reinterpret_cast<quintptr>(QThread::currentThreadId()))
        .arg(message);

    fprintf(stderr, "%s\n", qPrintable(line));
    fflush(stderr);

    if (g_logFile.isOpen()) {
        QTextStream stream(&g_logFile);
        stream << line << Qt::endl;
        stream.flush();
    }

    if (type == QtFatalMsg) {
        std::abort();
    }
}

bool initializeEnterpriseLogging()
{
    const QString dirPath = logDirectoryPath();
    if (!QDir().mkpath(dirPath))
        return false;

    const QString currentPath = dirPath + "/voidone_enterprise.log";
    const QString previousPath = dirPath + "/voidone_enterprise.log.old";

    if (QFile::exists(previousPath))
        QFile::remove(previousPath);
    if (QFile::exists(currentPath))
        QFile::rename(currentPath, previousPath);

    g_logFile.setFileName(currentPath);
    return g_logFile.open(QIODevice::WriteOnly | QIODevice::Text);
}

// Signal handlers run in an extremely restricted execution context. Do not
// touch Qt, heap allocation, mutexes, QFile, QDebug, or other non-signal-safe
// facilities here. Crash reporting/log flushing belongs outside the handler.
void fatalSignalHandler(int signalNumber)
{
    std::_Exit(128 + signalNumber);
}

void registerEnterpriseSignalHandlers()
{
    std::signal(SIGSEGV, fatalSignalHandler);
    std::signal(SIGABRT, fatalSignalHandler);
    std::signal(SIGFPE, fatalSignalHandler);
    std::signal(SIGILL, fatalSignalHandler);
}

} // namespace

int main(int argc, char *argv[])
{
    registerEnterpriseSignalHandlers();

    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("VoidOne_app");
    QCoreApplication::setOrganizationDomain("voidone.app");
    QCoreApplication::setApplicationName("VoidOne");
    QCoreApplication::setApplicationVersion(VOIDONE_VERSION_DISPLAY);

    QCommandLineParser parser;
    parser.setApplicationDescription("VoidOne — High-Performance PC Game Launcher.");
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addOption(QCommandLineOption(
        {"d", "diagnostics"},
        "Run system telemetry and diagnostic suite on startup."));
    parser.process(app);

    if (!initializeEnterpriseLogging())
        fprintf(stderr, "[CRITICAL] Failed to initialize file logging backend.\n");
    qInstallMessageHandler(enterpriseMessageHandler);

    qInfo() << "============================================================";
    qInfo() << "              VOIDONE LAUNCHER INITIALIZING                ";
    qInfo() << "Version          :" << QCoreApplication::applicationVersion();
    qInfo() << "Qt               :" << QT_VERSION_STR;
    qInfo() << "Operating System :" << QSysInfo::prettyProductName();
    qInfo() << "Architecture     :" << QSysInfo::currentCpuArchitecture();

    const QString lockFilePath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)
        + "/voidone_enterprise.lock";
    QLockFile singleInstanceLock(lockFilePath);
    singleInstanceLock.setStaleLockTime(0);

    if (!singleInstanceLock.tryLock(200)) {
        qCritical() << "[Security] Another VoidOne instance is already active.";
        return -1;
    }

    try {
        qInfo() << "[Database] Initializing SQLite storage...";
        if (!Database::initialize()) {
            qCritical() << "[Database] Initialization failed.";
            return -1;
        }

        GameModel gameModel;
        gameModel.loadGamesFromDatabase();
        SaveBackupManager saveBackupManager;
        SteamScanner steamScanner;
        TranslationManager trManager;

        QQmlApplicationEngine engine;
        QQmlContext *rootContext = engine.rootContext();
        rootContext->setContextProperty("gameModel", &gameModel);
        rootContext->setContextProperty("saveBackupManager", &saveBackupManager);
        rootContext->setContextProperty("steamScanner", &steamScanner);
        rootContext->setContextProperty("trManager", &trManager);

        QObject::connect(
            &engine,
            &QQmlApplicationEngine::objectCreationFailed,
            &app,
            []() {
                qCritical() << "[UI-FATAL] Root QML component creation failed.";
                QCoreApplication::exit(-1);
            },
            Qt::QueuedConnection);

        QObject::connect(&app, &QCoreApplication::aboutToQuit, []() {
            qInfo() << "[Lifecycle] Shutdown sequence initiated.";
            QMutexLocker locker(&g_logMutex);
            if (g_logFile.isOpen())
                g_logFile.close();
        });

        engine.loadFromModule("VoidOne", "Main");
        if (engine.rootObjects().isEmpty()) {
            qCritical() << "[UI-FATAL] No root QML object was created.";
            return -1;
        }

        return app.exec();
    } catch (const std::bad_alloc &ex) {
        qCritical() << "[Memory-FATAL] Out of memory:" << ex.what();
        return -1;
    } catch (const std::exception &ex) {
        qCritical() << "[Exception-FATAL] Unhandled exception:" << ex.what();
        return -1;
    } catch (...) {
        qCritical() << "[Exception-FATAL] Unknown exception.";
        return -1;
    }
}
