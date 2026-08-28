#include "SteamScanner.h"
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QStandardPaths>
#include <QRegularExpression>
#include <QDebug>

void SteamScannerWorker::doScan() {
    QVector<GameRecord> games;
    QString steamPath = "";

#if defined(Q_OS_WIN)
    steamPath = "C:/Program Files (x86)/Steam";
#elif defined(Q_OS_LINUX)
    QString home = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    steamPath = home + "/.local/share/Steam";
    if (!QDir(steamPath).exists()) {
        steamPath = home + "/.var/app/com.valvesoftware.Steam/.local/share/Steam";
    }
#endif

    QString steamappsPath = steamPath + "/steamapps";
    QDir steamappsDir(steamappsPath);

    if (steamappsDir.exists()) {
        QStringList filters;
        filters << "appmanifest_*.acf";
        QFileInfoList manifestFiles = steamappsDir.entryInfoList(filters, QDir::Files);

        QRegularExpression nameRx("\"name\"\\s+\"([^\"]+)\"");
        QRegularExpression dirRx("\"installdir\"\\s+\"([^\"]+)\"");

        for (const QFileInfo &fileInfo : manifestFiles) {
            QFile file(fileInfo.absoluteFilePath());
            if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
                QString content = file.readAll();
                file.close();

                auto nameMatch = nameRx.match(content);
                auto dirMatch = dirRx.match(content);

                if (nameMatch.hasMatch() && dirMatch.hasMatch()) {
                    GameRecord rec;
                    rec.name = nameMatch.captured(1);
                    rec.exePath = steamappsPath + "/common/" + dirMatch.captured(1);
                    rec.platform = "Steam";
                    games.append(rec);
                }
            }
        }
    }

    emit scanFinished(games);
}

SteamScanner::SteamScanner(QObject *parent) : QObject(parent) {
    worker = new SteamScannerWorker;
    worker->moveToThread(&workerThread);

    connect(&workerThread, &QThread::finished, worker, &QObject::deleteLater);
    connect(worker, &SteamScannerWorker::scanFinished, this, &SteamScanner::handleScanFinished);
    
    workerThread.start();
}

SteamScanner::~SteamScanner() {
    workerThread.quit();
    workerThread.wait();
}

void SteamScanner::startAsyncScan() {
    if (!workerThread.isRunning() || worker == nullptr) {
        qWarning() << "[VoidOne] Steam scanner worker thread is not available.";
        emit scanCompleted(0);
        return;
    }

    QMetaObject::invokeMethod(worker, &SteamScannerWorker::doScan, Qt::QueuedConnection);
}

void SteamScanner::handleScanFinished(const QVector<GameRecord>& games) {
    Database::addGamesBatch(games);
    emit scanCompleted(games.size());
}
