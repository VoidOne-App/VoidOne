#pragma once

#include <QObject>
#include <QString>
#include <QDir>
#include <QTimer>

class SaveBackupManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool autoSaveEnabled READ isAutoSaveEnabled WRITE setAutoSaveEnabled NOTIFY autoSaveEnabledChanged)
    Q_PROPERTY(int autoSaveIntervalSeconds READ autoSaveIntervalSeconds WRITE setAutoSaveIntervalSeconds NOTIFY autoSaveIntervalChanged)
    Q_PROPERTY(int maxBackups READ maxBackups WRITE setMaxBackups NOTIFY maxBackupsChanged)
    Q_PROPERTY(QString saveDirPath READ saveDirPath NOTIFY pathsChanged)
    Q_PROPERTY(QString backupDestinationPath READ backupDestinationPath NOTIFY pathsChanged)

public:
    explicit SaveBackupManager(QObject *parent = nullptr);

    Q_INVOKABLE bool createBackup(const QString &saveDirPath, const QString &backupDestinationPath);
    Q_INVOKABLE bool restoreBackup(const QString &backupFilePath, const QString &targetSaveDirPath);
    Q_INVOKABLE QString latestBackupPath(const QString &backupDestinationPath);

    bool isAutoSaveEnabled() const { return m_autoSaveEnabled; }
    void setAutoSaveEnabled(bool enabled);

    int autoSaveIntervalSeconds() const { return m_intervalSeconds; }
    void setAutoSaveIntervalSeconds(int seconds);

    int maxBackups() const { return m_maxBackups; }
    void setMaxBackups(int count);

    QString saveDirPath() const { return m_targetSaveDir; }
    QString backupDestinationPath() const { return m_destinationDir; }

    Q_INVOKABLE void configureAutoSave(const QString &saveDirPath, const QString &backupDestinationPath);

signals:
    void backupCompleted(bool success, const QString &message);
    void autoSaveEnabledChanged(bool enabled);
    void autoSaveIntervalChanged(int seconds);
    void maxBackupsChanged(int count);
    void pathsChanged();

private slots:
    void performAutoSave();

private:
    bool copyRecursively(const QString &srcFilePath, const QString &tgtFilePath);
    void pruneOldBackups(const QString &backupDestinationPath) const;

    QTimer *m_autoSaveTimer = nullptr;
    bool m_autoSaveEnabled = false;
    int m_intervalSeconds = 60;
    int m_maxBackups = 20;
    QString m_targetSaveDir;
    QString m_destinationDir;
};
