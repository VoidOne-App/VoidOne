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
#include <QCommandLineParser>
#include <QStandardPaths>
#include <QLockFile>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QDebug>

#include <exception>

// ماژول‌های بک‌اند (++C)
#include "Database.h"
#include "GameModel.h"
#include "SaveBackupManager.h"
#include "SteamScanner.h"
#include "TranslationManager.h"

// نسخه‌ی خودکار از git tag — تولیدشده توسط CMake، دستی ادیت نشه
#include "VoidOneVersion.h"

namespace {

// ============================================================================
// File-Backed Logging
// ============================================================================
// Console output alone isn't useful once the app is in a user's hands — you
// can't ask a non-technical user to "open a terminal and check." Every
// message still goes to the console (same as before) but also lands in a
// persistent log file the user can attach to a bug report.
// ============================================================================

QFile g_logFile;

QString logDirectoryPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/logs";
}

void voidOneMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message)
{
    Q_UNUSED(context)

    const char *levelTag = "INFO ";
    switch (type) {
        case QtDebugMsg:    levelTag = "DEBUG"; break;
        case QtInfoMsg:     levelTag = "INFO "; break;
        case QtWarningMsg:  levelTag = "WARN "; break;
        case QtCriticalMsg: levelTag = "CRIT "; break;
        case QtFatalMsg:    levelTag = "FATAL"; break;
    }

    const QString line = QStringLiteral("[%1] [%2] %3")
        .arg(QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss"))
        .arg(levelTag)
        .arg(message);

    // Always echo to the console (stderr), same behavior as Qt's default.
    fprintf(stderr, "%s\n", qPrintable(line));
    fflush(stderr);

    // Best-effort file write — if this fails, we still have the console.
    if (g_logFile.isOpen()) {
        QTextStream stream(&g_logFile);
        stream << line << Qt::endl;
    }

    if (type == QtFatalMsg) {
        abort();
    }
}

bool initializeLogFile()
{
    const QString dirPath = logDirectoryPath();
    QDir().mkpath(dirPath);

    const QString currentPath = dirPath + "/voidone.log";
    const QString previousPath = dirPath + "/voidone.log.old";

    // Keep exactly one rotated backup rather than growing forever.
    QFile::remove(previousPath);
    QFile::rename(currentPath, previousPath);

    g_logFile.setFileName(currentPath);
    return g_logFile.open(QIODevice::WriteOnly | QIODevice::Text);
}

} // namespace

int main(int argc, char *argv[])
{
    // ۱. تنظیمات پایه‌ای اپلیکیشن (یکپارچه با برند VoidOne)
    QCoreApplication::setOrganizationName("VoidOne-App");
    QCoreApplication::setOrganizationDomain("voidone.app");
    QCoreApplication::setApplicationName("VoidOne");

    // نسخه از git tag می‌آد، نه هاردکد — با هر ریلیز خودش آپدیت می‌شه
    QCoreApplication::setApplicationVersion(VOIDONE_VERSION_DISPLAY);

    QGuiApplication app(argc, argv);

    // ۲. پارس آرگومان‌های خط فرمان — ‎--version و ‎--help رایگان از Qt می‌آن
    QCommandLineParser parser;
    parser.setApplicationDescription("VoidOne — a lightweight, open-source PC game launcher.");
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption verboseOption(
        QStringList() << "v" << "verbose",
        "Enable verbose debug logging."
    );
    parser.addOption(verboseOption);
    parser.process(app);

    // ۳. راه‌اندازی لاگ فایل قبل از هر چیز دیگه، تا هیچ رویدادی از دست نره
    const bool logFileReady = initializeLogFile();
    qInstallMessageHandler(voidOneMessageHandler);

    if (!logFileReady) {
        qWarning() << "[VoidOne] Could not open log file — continuing with console-only logging.";
    }

    qDebug() << "\n[VoidOne] =========================================";
    qDebug() << "[VoidOne] Boot sequence initiated... Version:" << QCoreApplication::applicationVersion();
    qDebug() << "[VoidOne] Log file:" << logDirectoryPath() + "/voidone.log";

    // ۴. جلوگیری از اجرای هم‌زمان چند نمونه (چون SQLite با چند writer هم‌زمان مشکل پیدا می‌کنه)
    QLockFile singleInstanceLock(
        QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/voidone.lock"
    );
    singleInstanceLock.setStaleLockTime(0); // اجازه نده یه لاک قدیمیِ باقی‌مانده از کرش قبلی مانع اجرا بشه

    if (!singleInstanceLock.tryLock(100)) {
        qCritical() << "[VoidOne] Another instance of VoidOne is already running. Exiting.";
        return -1;
    }

    // ۵. اجرای منطق اصلی زیر try/catch — یه exception مدیریت‌نشده نباید بی‌صدا کرش کنه
    try {
        // راه‌اندازی دیتابیس در خط مقدم (اگر بالا نیاد، برنامه کرش مدیریت‌شده میده)
        if (!Database::initialize()) {
            qCritical() << "[VoidOne] FATAL: Failed to initialize the SQLite database.";
            return -1;
        }
        qDebug() << "[VoidOne] SQLite Database mounted successfully.";

        // ساخت نمونه (Instance) از سیستم‌های بک‌اند و لود دیتای اولیه
        GameModel gameModel;
        gameModel.loadGamesFromDatabase(); // بارگذاری لیست بازی‌ها از دیتابیس

        SaveBackupManager saveBackupManager;
        SteamScanner steamScanner;
        TranslationManager trManager;

        qDebug() << "[VoidOne] Backend controllers instantiated.";

        // راه‌اندازی موتور QML
        QQmlApplicationEngine engine;

        // تزریق کلاس‌های ++C به موتور QML (دقیقاً با نام‌های استفاده شده در UI)
        QQmlContext *context = engine.rootContext();
        context->setContextProperty("gameModel", &gameModel);
        context->setContextProperty("saveBackupManager", &saveBackupManager);
        context->setContextProperty("steamScanner", &steamScanner);
        context->setContextProperty("trManager", &trManager);

        qDebug() << "[VoidOne] Context properties injected into QML.";

        // اتصال سیگنال‌های ایمنی برای جلوگیری از کرش‌های بی‌صدا
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

        // لاگ خروج تمیز، برای اینکه توی فایل لاگ مشخص باشه اپ عادی بسته شده نه کرش کرده
        QObject::connect(&app, &QCoreApplication::aboutToQuit, []() {
            qDebug() << "[VoidOne] Shutdown sequence complete. Goodbye.";
        });

        // بارگذاری ماژول اصلی رابط کاربری
        qDebug() << "[VoidOne] Loading primary QML module (Main.qml)...";
        engine.loadFromModule("VoidOne", "Main");

        if (engine.rootObjects().isEmpty()) {
            qCritical() << "[VoidOne] FATAL: QML Engine is empty after load.";
            return -1;
        }

        qDebug() << "[VoidOne] UI rendered successfully. Entering Event Loop.";
        qDebug() << "[VoidOne] =========================================\n";

        return app.exec();

    } catch (const std::exception &ex) {
        qCritical() << "[VoidOne] FATAL: Unhandled exception:" << ex.what();
        return -1;
    } catch (...) {
        qCritical() << "[VoidOne] FATAL: Unknown unhandled exception.";
        return -1;
    }
}
