/****************************************************************************
**  V O I D O N E   E N G I N E  [CORE]
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
#include <cstdio>

#ifdef Q_OS_WIN
#include <windows.h>
#include <strsafe.h>
#endif

#include "VoidOneVersion.h"
#include "Database.h"
#include "GameModel.h"
#include "SaveBackupManager.h"
#include "SteamScanner.h"
#include "TranslationManager.h"

namespace {

QMutex g_logMutex;
QFile g_logFile;

QString appDataDirectory()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
}

QString logDirectoryPath()
{
    return QDir(appDataDirectory()).filePath("logs");
}

void enterpriseMessageHandler(QtMsgType type, const QMessageLogContext &context,
                              const QString &message)
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

    if (type == QtFatalMsg)
        std::abort();
}

bool initializeEnterpriseLogging()
{
    const QString dirPath = logDirectoryPath();
    if (!QDir().mkpath(dirPath))
        return false;

    const QString currentPath = QDir(dirPath).filePath("voidone_enterprise.log");
    const QString previousPath = QDir(dirPath).filePath("voidone_enterprise.log.old");

    if (QFile::exists(previousPath))
        QFile::remove(previousPath);
    if (QFile::exists(currentPath) && !QFile::rename(currentPath, previousPath))
        return false;

    g_logFile.setFileName(currentPath);
    return g_logFile.open(QIODevice::WriteOnly | QIODevice::Text);
}

#ifdef Q_OS_WIN
void writeWindowsCrashRecord(const LPEXCEPTION_POINTERS exceptionInfo)
{
    const QString dirPath = logDirectoryPath();
    if (!QDir().mkpath(dirPath))
        return;

    const QString filePath = QDir(dirPath).filePath("VoidOne-crash.log");
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text))
        return;

    const DWORD code = exceptionInfo && exceptionInfo->ExceptionRecord
        ? exceptionInfo->ExceptionRecord->ExceptionCode : 0;
    const ULONG_PTR address = exceptionInfo && exceptionInfo->ExceptionRecord
        ? reinterpret_cast<ULONG_PTR>(exceptionInfo->ExceptionRecord->ExceptionAddress) : 0;

    QTextStream stream(&file);
    stream << "VoidOne fatal Windows exception\n"
           << "Timestamp=" << QDateTime::currentDateTime().toString(Qt::ISODateWithMs) << '\n'
           << "ExceptionCode=0x" << QString::number(code, 16) << '\n'
           << "ExceptionAddress=0x" << QString::number(address, 16) << "\n\n";
}

LONG WINAPI windowsUnhandledExceptionFilter(LPEXCEPTION_POINTERS exceptionInfo)
{
    writeWindowsCrashRecord(exceptionInfo);
    return EXCEPTION_EXECUTE_HANDLER;
}

void registerWindowsCrashHandler()
{
    SetUnhandledExceptionFilter(windowsUnhandledExceptionFilter);
}
#endif

#if !defined(Q_OS_WIN)
void fatalSignalHandler(int signalNumber)
{
    // Keep the handler async-signal-safe: no Qt allocation or logging here.
    std::_Exit(128 + signalNumber);
}

void registerEnterpriseSignalHandlers()
{
    std::signal(SIGSEGV, fatalSignalHandler);
    std::signal(SIGABRT, fatalSignalHandler);
    std::signal(SIGFPE, fatalSignalHandler);
    std::signal(SIGILL, fatalSignalHandler);
}
#endif

} // namespace

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    registerWindowsCrashHandler();
#else
    registerEnterpriseSignalHandlers();
#endif

    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("VoidOne_app");
    QCoreApplication::setOrganizationDomain("voidone.app");
    QCoreApplication::setApplicationName("VoidOne");
    QCoreApplication::setApplicationVersion(VOIDONE_VERSION_DISPLAY);

    // AppDataLocation must exist before anything such as QLockFile uses it.
    const QString appDataDir = appDataDirectory();
    if (appDataDir.isEmpty() || !QDir().mkpath(appDataDir)) {
        fprintf(stderr, "[CRITICAL] Failed to create VoidOne application data directory.\n");
        return -1;
    }

    QCommandLineParser parser;
    parser.setApplicationDescription("VoidOne — Open-source native PC game launcher.");
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addOption(QCommandLineOption({"d", "diagnostics"},
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

    const QString lockFilePath = QDir(appDataDir).filePath("voidone_enterprise.lock");
    QLockFile singleInstanceLock(lockFilePath);
    // Recover automatically from a lock left by a crashed process.\n    singleInstanceLock.setStaleLockTime(30000);

    if (!singleInstanceLock.tryLock(200)) {
        qCritical() << "[Lifecycle] Another VoidOne instance is already active.";
        return -1;
    }

    int exitCode = -1;
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

        QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                         &app, []() {
            qCritical() << "[UI-FATAL] Root QML component creation failed.";
            QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);

        engine.loadFromModule("VoidOne", "Main");
        if (engine.rootObjects().isEmpty()) {
            qCritical() << "[UI-FATAL] No root QML object was created.";
            return -1;
        }

        QObject::connect(&app, &QCoreApplication::aboutToQuit, [&]() {
            qInfo() << "[Lifecycle] Shutdown sequence initiated.";
            saveBackupManager.setAutoSaveEnabled(false);
            Database::shutdown();

            QMutexLocker locker(&g_logMutex);
            if (g_logFile.isOpen())
                g_logFile.close();
        });

        exitCode = app.exec();
    } catch (const std::bad_alloc &ex) {
        qCritical() << "[Memory-FATAL] Out of memory:" << ex.what();
    } catch (const std::exception &ex) {
        qCritical() << "[Exception-FATAL] Unhandled exception:" << ex.what();
    } catch (...) {
        qCritical() << "[Exception-FATAL] Unknown exception.";
    }

    return exitCode;
}
