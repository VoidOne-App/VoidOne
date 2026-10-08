/****************************************************************************
**  V O I D O N E   E N G I N E  [CORE]
**  SPDX-License-Identifier: LicenseRef-VoidOne-Community-License-1.0
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
#include <cstdlib>
#include <cstdio>
#include <string>

#ifndef Q_OS_WIN
#include <csignal>
#endif

#ifdef Q_OS_WIN
#include <windows.h>
#include <dbghelp.h>
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
#ifdef Q_OS_WIN
    // Logs are machine-local diagnostics and must live beside the Windows
    // LOCALAPPDATA tree used by the installer/CI smoke test. Keep the main
    // persistent application data location unchanged for compatibility.
    const QString localData = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    return QDir(localData).filePath("logs");
#else
    return QDir(appDataDirectory()).filePath("logs");
#endif
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

void writeBootstrapMarker()
{
    QMutexLocker locker(&g_logMutex);
    if (!g_logFile.isOpen())
        return;

    QTextStream stream(&g_logFile);
    stream << "[Bootstrap] VoidOne process starting." << Qt::endl;
    stream.flush();
}

#ifdef Q_OS_WIN
bool writeWindowsMiniDump(EXCEPTION_POINTERS *exceptionInfo)
{
    wchar_t localAppData[MAX_PATH] = {};
    const DWORD length = GetEnvironmentVariableW(L"LOCALAPPDATA", localAppData, MAX_PATH);
    if (length == 0 || length >= MAX_PATH)
        return false;

    wchar_t appDir[MAX_PATH] = {};
    wchar_t vendorDir[MAX_PATH] = {};
    wchar_t logDir[MAX_PATH] = {};
    if (FAILED(StringCchPrintfW(appDir, MAX_PATH, L"%s\\VoidOne_app", localAppData))
        || FAILED(StringCchPrintfW(vendorDir, MAX_PATH, L"%s\\VoidOne_app\\VoidOne", localAppData))
        || FAILED(StringCchPrintfW(logDir, MAX_PATH, L"%s\\VoidOne_app\\VoidOne\\logs", localAppData)))
        return false;

    CreateDirectoryW(appDir, nullptr);
    CreateDirectoryW(vendorDir, nullptr);
    CreateDirectoryW(logDir, nullptr);

    SYSTEMTIME time;
    GetLocalTime(&time);

    wchar_t dumpPath[MAX_PATH] = {};
    if (FAILED(StringCchPrintfW(
            dumpPath, MAX_PATH,
            L"%s\\VoidOne-crash-%04u%02u%02u-%02u%02u%02u.dmp",
            logDir, time.wYear, time.wMonth, time.wDay,
            time.wHour, time.wMinute, time.wSecond)))
        return false;

    HANDLE dumpFile = CreateFileW(
        dumpPath, GENERIC_WRITE, FILE_SHARE_READ, nullptr,
        CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (dumpFile == INVALID_HANDLE_VALUE)
        return false;

    MINIDUMP_EXCEPTION_INFORMATION exceptionData{};
    exceptionData.ThreadId = GetCurrentThreadId();
    exceptionData.ExceptionPointers = exceptionInfo;
    exceptionData.ClientPointers = FALSE;

    const MINIDUMP_TYPE dumpType =
        static_cast<MINIDUMP_TYPE>(
            MiniDumpWithIndirectlyReferencedMemory | MiniDumpScanMemory);

    const BOOL dumped = MiniDumpWriteDump(
        GetCurrentProcess(), GetCurrentProcessId(), dumpFile,
        dumpType,
        exceptionInfo ? &exceptionData : nullptr, nullptr, nullptr);

    CloseHandle(dumpFile);
    return dumped == TRUE;
}

LONG WINAPI windowsUnhandledExceptionFilter(EXCEPTION_POINTERS *exceptionInfo)
{
    writeWindowsMiniDump(exceptionInfo);
    return EXCEPTION_EXECUTE_HANDLER;
}

void registerWindowsCrashHandler()
{
    SetUnhandledExceptionFilter(windowsUnhandledExceptionFilter);
}
#endif

#ifndef Q_OS_WIN
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
#endif

} // namespace

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    registerWindowsCrashHandler();
#else
    registerEnterpriseSignalHandlers();
#endif

    // Set application metadata before QGuiApplication so QStandardPaths and
    // Qt's own startup diagnostics resolve to the same per-user location.
    QCoreApplication::setOrganizationName("VoidOne_app");
    QCoreApplication::setOrganizationDomain("voidone.app");
    QCoreApplication::setApplicationName("VoidOne");
    QCoreApplication::setApplicationVersion(VOIDONE_VERSION_DISPLAY);

    // Install the message handler before QGuiApplication is constructed.
    // A Windows GUI executable has no attached console by design, so QPA/plugin
    // failures can otherwise look like a completely silent process exit.
    if (!initializeEnterpriseLogging())
        fprintf(stderr, "[CRITICAL] Failed to initialize early file logging backend.\n");
    qInstallMessageHandler(enterpriseMessageHandler);

    // Write the CI bootstrap marker directly to the log file so it remains
    // deterministic even if Qt message filtering changes on Windows.
    writeBootstrapMarker();

    qInfo() << "[Bootstrap] VoidOne process starting.";
    qInfo() << "[Bootstrap] Executable:" << QCoreApplication::applicationFilePath();
    qInfo() << "[Bootstrap] Working directory:" << QDir::currentPath();
    qInfo() << "[Bootstrap] QT_QPA_PLATFORM:" << qEnvironmentVariable("QT_QPA_PLATFORM");
    qInfo() << "[Bootstrap] QT_PLUGIN_PATH:" << qEnvironmentVariable("QT_PLUGIN_PATH");
    qInfo() << "[Bootstrap] QML2_IMPORT_PATH:" << qEnvironmentVariable("QML2_IMPORT_PATH");

    QGuiApplication app(argc, argv);

    // AppDataLocation must exist before anything such as QLockFile uses it.
    const QString appDataDir = appDataDirectory();
    if (appDataDir.isEmpty() || !QDir().mkpath(appDataDir)) {
        fprintf(stderr, "[CRITICAL] Failed to create VoidOne application data directory.\n");
        return -1;
    }

    QCommandLineParser parser;
    parser.setApplicationDescription("VoidOne - Native PC Gaming Platform.");
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addOption(QCommandLineOption({"d", "diagnostics"},
        "Run system telemetry and diagnostic suite on startup."));
    parser.process(app);

    qInfo() << "============================================================";
    qInfo() << "              VOIDONE PLATFORM INITIALIZING                ";
    qInfo() << "Version          :" << QCoreApplication::applicationVersion();
    qInfo() << "Qt               :" << QT_VERSION_STR;
    qInfo() << "Operating System :" << QSysInfo::prettyProductName();
    qInfo() << "Architecture     :" << QSysInfo::currentCpuArchitecture();

    const QString lockFilePath = QDir(appDataDir).filePath("voidone_enterprise.lock");
    QLockFile singleInstanceLock(lockFilePath);
    // Recover automatically from a lock left by a crashed process.
    singleInstanceLock.setStaleLockTime(30000);

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

        engine.loadFromModule("VoidOne.App", "Main");
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
