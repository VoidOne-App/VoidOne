#pragma once

#include <QObject>
#include <QString>
#include <QDir>
#include <QTimer>

class SaveBackupManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool autoSaveEnabled READ isAutoSaveEnabled WRITE setAutoSaveEnabled NOTIFY autoSaveEnabledChanged)
    Q_PROPERTY(int autoSaveIntervalSeconds READ autoSaveIntervalSeconds WRITE setAutoSaveIntervalSeconds NOTIFY autoSaveIntervalChanged)

public:
    explicit SaveBackupManager(QObject *parent = nullptr);

    // Manual backup and restore methods (توابع دستی بکاپ و ریستور)
    Q_INVOKABLE bool createBackup(const QString &saveDirPath, const QString &backupDestinationPath);
    Q_INVOKABLE bool restoreBackup(const QString &backupFilePath, const QString &targetSaveDirPath);
    Q_INVOKABLE QString latestBackupPath(const QString &backupDestinationPath);

    // Auto-save settings management (مدیریت تنظیمات ذخیره خودکار)
    bool isAutoSaveEnabled() const { return m_autoSaveEnabled; }
    void setAutoSaveEnabled(bool enabled);

    int autoSaveIntervalSeconds() const { return m_intervalSeconds; }
    void setAutoSaveIntervalSeconds(int seconds);

    // Configure paths for real-time auto-saving (تنظیم مسیرها برای بکاپ لحظه‌ای)
    Q_INVOKABLE void configureAutoSave(const QString &saveDirPath, const QString &backupDestinationPath);

signals:
    void backupCompleted(bool success, const QString &message);
    void autoSaveEnabledChanged(bool enabled);
    void autoSaveIntervalChanged(int seconds);

private slots:
    void performAutoSave();

private:
    bool copyRecursively(const QString &srcFilePath, const QString &tgtFilePath);

    QTimer *m_autoSaveTimer;
    bool m_autoSaveEnabled = false;
    int m_intervalSeconds = 60; // Default: every 60 seconds (پیش‌فرض: هر ۶۰ ثانیه)
    QString m_targetSaveDir;
    QString m_destinationDir;
};
