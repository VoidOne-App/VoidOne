/****************************************************************************
** 
**  V O I D O N E   E N G I N E   [ENTERPRISE CORE]
**  High-Performance Cross-Platform QML & C++ Game Launcher Architecture
** 
**  Copyright (C) 2026 VoidOne-App Core Team
**  Repository: https://github.com/VoidOne-App/VoidOne
**  SPDX-License-Identifier: MIT
** 
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

// Auto-generated version header from CMake build pipeline
#include "VoidOneVersion.h"

// C++ Backend Business Controllers
#include "Database.h"
#include "GameModel.h"
#include "SaveBackupManager.h"
#include "SteamScanner.h"
#include "TranslationManager.h"

namespace {

// Thread-safe logging mechanism using Mutex locking
QMutex g_logMutex;
QFile g_logFile;

QString logDirectoryPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/logs";
}

void enterpriseMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message)
{
    QMutexLocker locker(&g_logMutex);
    Q_UNUSED(context)

    const char *levelTag = "INFO ";
    switch (type) {
        case QtDebugMsg:    levelTag = "DEBUG"; break;
        case QtInfoMsg:     levelTag = "INFO "; break;
        case QtWarningMsg:  levelTag = "WARN "; break;
        case QtCriticalMsg: levelTag = "CRIT "; break;
        case QtFatalMsg:    levelTag = "FATAL"; break;
    }

    const QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss.zzz");
    const QString line = QStringLiteral("[%1] [%2] [TID %3] %4")
        .arg(timestamp)
        .arg(levelTag)
        .arg(reinterpret_cast<quintptr>(QThread::currentThreadId()))
        .arg(message);

    // Standard Error Stream Output
    fprintf(stderr, "%s\n", qPrintable(line));
    fflush(stderr);

    // Persistent Enterprise File Stream Output
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
    if (!QDir().mkpath(dirPath)) {
        return false;
    }

    const QString currentPath = dirPath + "/voidone_enterprise.log";
    const QString previousPath = dirPath + "/voidone_enterprise.log.old";

    // Enterprise Log Rotation Protocol
    if (QFile::exists(previousPath)) {
        QFile::remove(previousPath);
    }
    if (QFile::exists(currentPath)) {
        QFile::rename(currentPath, previousPath);
    }

    g_logFile.setFileName(currentPath);
    return g_logFile.open(QIODevice::WriteOnly | QIODevice::Text);
}

void registerEnterpriseSignalHandlers()
{
    auto signalHandler = [](int signal) {
        qCritical() << "[VoidOne-Enterprise] FATAL SIGNAL INTERCEPTED: " << signal;
        QMutexLocker locker(&g_logMutex);
        if (g_logFile.isOpen()) {
            g_logFile.flush();
            g_logFile.close();
        }
        std::_Exit(128 + signal);
    };

    std::signal(SIGSEGV, signalHandler);
    std::signal(SIGABRT, signalHandler);
    std::signal(SIGFPE, signalHandler);
    std::signal(SIGILL, signalHandler);
}

} // namespace

int main(int argc, char *argv[])
{
    // 0. Hardened Environment & Signal Interception Setup
    registerEnterpriseSignalHandlers();

    // High-DPI scaling is automatic in Qt 6. Keep Qt 5 attributes guarded for compatibility.
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling, true);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);
#endif

    QGuiApplication app(argc, argv);

    // Core Metadata Architecture
    QCoreApplication::setOrganizationName("VoidOne-App-Enterprise");
    QCoreApplication::setOrganizationDomain("voidone.app");
    QCoreApplication::setApplicationName("VoidOne");
    QCoreApplication::setApplicationVersion(VOIDONE_VERSION_DISPLAY);

    // 1. Enterprise CLI Parser Architecture
    QCommandLineParser parser;
    parser.setApplicationDescription("VoidOne — High-Performance Enterprise PC Game Launcher Core.");
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption diagnosticOption(
        QStringList() << "d" << "diagnostics",
        "Run system telemetry and diagnostic suite on startup."
    );
    parser.addOption(diagnosticOption);
    parser.process(app);

    // 2. Initialize Enterprise Logging Subsystem
    if (!initializeEnterpriseLogging()) {
        fprintf(stderr, "[CRITICAL] Failed to initialize enterprise file logging backend.\n");
    }
    qInstallMessageHandler(enterpriseMessageHandler);

    qInfo() << "============================================================";
    qInfo() << "          VOIDONE ENTERPRISE LAUNCHER INITIALIZING          ";
    qInfo() << "============================================================";
    qInfo() << "App Identity     :" << QCoreApplication::applicationName();
    qInfo() << "Version Build    :" << QCoreApplication::applicationVersion();
    qInfo() << "Qt Framework     :" << QT_VERSION_STR;
    qInfo() << "Operating System :" << QSysInfo::prettyProductName();
    qInfo() << "Kernel Architecture:" << QSysInfo::currentCpuArchitecture();
    qInfo() << "Host Machine     :" << QSysInfo::machineHostName();
    qInfo() << "Log Target Path  :" << logDirectoryPath() + "/voidone_enterprise.log";
    qInfo() << "============================================================";

    // 3. Exclusive Single-Instance Enforcement (Mutex + File Locking)
    const QString lockFilePath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/voidone_enterprise.lock";
    QLockFile singleInstanceLock(lockFilePath);
    singleInstanceLock.setStaleLockTime(0);

    if (!singleInstanceLock.tryLock(200)) {
        qCritical() << "[Security] Lock acquisition failed. An instance of VoidOne is already active.";
        return -1;
    }
    qInfo() << "[Security] Exclusive instance lock acquired successfully at:" << lockFilePath;

    // 4. Main Core Execution Pipeline Protected By Enterprise Try-Catch
    try {
        // Initialize Core Relational Database Subsystem (SQLite)
        qInfo() << "[Database] Mounting SQLite persistent storage engine...";
        if (!Database::initialize()) {
            qCritical() << "[Database] FATAL ERROR: Database subsystem initialization failure.";
            return -1;
        }
        qInfo() << "[Database] Storage layer mounted and indexed successfully.";

        // Instantiate Core Domain Controllers
        qInfo() << "[Core] Instantiating business domain models and controllers...";
        GameModel gameModel;
        gameModel.loadGamesFromDatabase();

        SaveBackupManager saveBackupManager;
        SteamScanner steamScanner;
        TranslationManager trManager;
        qInfo() << "[Core] All backend subsystem controllers loaded.";

        // QML Engine Pipeline Setup
        QQmlApplicationEngine engine;

        QQmlContext *rootContext = engine.rootContext();
        rootContext->setContextProperty("gameModel", &gameModel);
        rootContext->setContextProperty("saveBackupManager", &saveBackupManager);
        rootContext->setContextProperty("steamScanner", &steamScanner);
        rootContext->setContextProperty("trManager", &trManager);
        qInfo() << "[QML] Backend context properties successfully exposed to QML engine.";

        // Signal Safety Connections
        QObject::connect(
            &engine,
            &QQmlApplicationEngine::objectCreationFailed,
            &app,
            []() {
                qCritical() << "[UI-FATAL] Root QML UI component instantiation failed critically.";
                QCoreApplication::exit(-1);
            },
            Qt::QueuedConnection
        );

        QObject::connect(&app, &QCoreApplication::aboutToQuit, []() {
            qInfo() << "[Lifecycle] Enterprise shutdown sequence initiated. Flushing buffers...";
            QMutexLocker locker(&g_logMutex);
            if (g_logFile.isOpen()) {
                g_logFile.close();
            }
        });

        // Load Main QML Interface Entrypoint
        qInfo() << "[UI] Loading primary QML visual container [Main.qml]...";
        engine.loadFromModule("VoidOne", "Main");

        if (engine.rootObjects().isEmpty()) {
            qCritical() << "[UI-FATAL] QML engine root object stack is entirely empty. Aborting execution.";
            return -1;
        }

        qInfo() << "[UI] Visual render loop operational. Entering main thread execution cycle.";
        qInfo() << "============================================================\n";

        return app.exec();

    } catch (const std::bad_alloc &ex) {
        qCritical() << "[Memory-FATAL] Out of memory exception caught:" << ex.what();
        return -1;
    } catch (const std::exception &ex) {
        qCritical() << "[Exception-FATAL] Unhandled standard exception caught:" << ex.what();
        return -1;
    } catch (...) {
        qCritical() << "[Exception-FATAL] Unknown non-standard system exception caught.";
        return -1;
    }
}
