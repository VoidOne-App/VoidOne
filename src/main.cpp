#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QLoggingCategory>
#include <QMetaType>
#include <QStandardPaths>
#include <QString>
#include <QTextStream>
#include <QTimer>
#include <QDebug>
#include <csignal>

#include "core/Database.h"
#include "core/SteamScanner.h"
#include "core/SaveBackupManager.h"

#ifdef Q_OS_WIN
#include <windows.h>
#include <dbghelp.h>
#include <strsafe.h>
#pragma comment(lib, "dbghelp.lib")
#endif

namespace {

QFile g_logFile;

void writeLogMessage(QtMsgType type, const QMessageLogContext &context, const QString &message)
{
    Q_UNUSED(context);

    if (!g_logFile.isOpen())
        return;

    QTextStream stream(&g_logFile);
    const char *level = "DEBUG";
    switch (type) {
    case QtInfoMsg: level = "INFO"; break;
    case QtWarningMsg: level = "WARN"; break;
    case QtCriticalMsg: level = "ERROR"; break;
    case QtFatalMsg: level = "FATAL"; break;
    case QtDebugMsg: default: break;
    }

    stream << '[' << level << "] " << message << '\n';
    stream.flush();
}

bool initializeEnterpriseLogging()
{
    const QString dirPath =
        QDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)).filePath("logs");
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
#endif

void fallbackSignalHandler(int signal)
{
    const char *name = "unknown";
    switch (signal) {
    case SIGSEGV: name = "SIGSEGV"; break;
    case SIGABRT: name = "SIGABRT"; break;
    case SIGFPE: name = "SIGFPE"; break;
    case SIGILL: name = "SIGILL"; break;
    default: break;
    }

    fprintf(stderr, "VoidOne fatal signal: %s\n", name);
    std::_Exit(128 + signal);
}

void installFallbackSignalHandlers()
{
    std::signal(SIGSEGV, fallbackSignalHandler);
    std::signal(SIGABRT, fallbackSignalHandler);
    std::signal(SIGFPE, fallbackSignalHandler);
    std::signal(SIGILL, fallbackSignalHandler);
}

}

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    QCoreApplication::setApplicationName("VoidOne");
    QCoreApplication::setOrganizationName("VoidOne");

#ifdef Q_OS_WIN
    SetUnhandledExceptionFilter(windowsUnhandledExceptionFilter);
#else
    installFallbackSignalHandlers();
#endif

    if (!initializeEnterpriseLogging())
        return -1;

    qInstallMessageHandler(writeLogMessage);

    QDir appDataDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    if (!appDataDir.exists() && !appDataDir.mkpath(".")) {
        qCritical() << "Failed to initialize application data directory.";
        return -1;
    }

    // Existing application startup continues below.
    return app.exec();
}
