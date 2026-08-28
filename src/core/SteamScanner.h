#ifndef STEAMSCANNER_H
#define STEAMSCANNER_H

#include <QObject>
#include <QThread>
#include <QVector>
#include "Database.h"

class SteamScannerWorker : public QObject {
    Q_OBJECT
public slots:
    void doScan();
signals:
    void scanFinished(const QVector<GameRecord>& games);
};

class SteamScanner : public QObject
{
    Q_OBJECT
public:
    explicit SteamScanner(QObject *parent = nullptr);
    ~SteamScanner();

    Q_INVOKABLE void startAsyncScan();

signals:
    void scanCompleted(int foundCount);

private slots:
    void handleScanFinished(const QVector<GameRecord>& games);

private:
    QThread workerThread;
    SteamScannerWorker *worker = nullptr;
};

#endif // STEAMSCANNER_H
