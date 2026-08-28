#include "SaveBackupManager.h"
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QDateTime>

SaveBackupManager::SaveBackupManager(QObject *parent) : QObject(parent) {
    m_autoSaveTimer = new QTimer(this);
    connect(m_autoSaveTimer, &QTimer::timeout, this, &SaveBackupManager::performAutoSave);
}

bool SaveBackupManager::createBackup(const QString &saveDirPath, const QString &backupDestinationPath) {
    QDir srcDir(saveDirPath);
    if (!srcDir.exists()) {
        emit backupCompleted(false, "Save directory does not exist! / پوشه سیو وجود ندارد!");
        return false;
    }

    // Generate precise timestamp for real-time/second-by-second backups
    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss");
    QString finalDestPath = backupDestinationPath + "/autosave_" + timestamp;

    QDir destDir(finalDestPath);
    if (!destDir.exists()) {
        destDir.mkpath(".");
    }

    bool success = copyRecursively(saveDirPath, finalDestPath);
    emit backupCompleted(success, success ? "Backup created successfully! / پشتیبان‌گیری با موفقیت انجام شد!" 
                                          : "Failed to create backup. / خطا در پشتیبان‌گیری.");
    return success;
}

bool SaveBackupManager::restoreBackup(const QString &backupFilePath, const QString &targetSaveDirPath) {
    bool success = copyRecursively(backupFilePath, targetSaveDirPath);
    emit backupCompleted(success, success ? "Backup restored successfully! / بازگردانی بکاپ با موفقیت انجام شد!" 
                                          : "Failed to restore backup. / خطا در بازگردانی بکاپ.");
    return success;
}

void SaveBackupManager::setAutoSaveEnabled(bool enabled) {
    if (m_autoSaveEnabled != enabled) {
        m_autoSaveEnabled = enabled;
        if (m_autoSaveEnabled) {
            m_autoSaveTimer->start(m_intervalSeconds * 1000);
            qDebug() << "Real-time Auto Save enabled with interval:" << m_intervalSeconds << "seconds.";
        } else {
            m_autoSaveTimer->stop();
            qDebug() << "Auto Save disabled.";
        }
        emit autoSaveEnabledChanged(m_autoSaveEnabled);
    }
}

void SaveBackupManager::setAutoSaveIntervalSeconds(int seconds) {
    if (m_intervalSeconds != seconds && seconds > 0) {
        m_intervalSeconds = seconds;
        if (m_autoSaveEnabled) {
            m_autoSaveTimer->start(m_intervalSeconds * 1000);
        }
        emit autoSaveIntervalChanged(m_intervalSeconds);
    }
}

void SaveBackupManager::configureAutoSave(const QString &saveDirPath, const QString &backupDestinationPath) {
    m_targetSaveDir = saveDirPath;
    m_destinationDir = backupDestinationPath;
}

void SaveBackupManager::performAutoSave() {
    if (m_targetSaveDir.isEmpty() || m_destinationDir.isEmpty()) {
        return;
    }
    createBackup(m_targetSaveDir, m_destinationDir);
}

bool SaveBackupManager::copyRecursively(const QString &srcFilePath, const QString &tgtFilePath) {
    QFileInfo srcInfo(srcFilePath);
    if (srcInfo.isDir()) {
        QDir targetDir(tgtFilePath);
        if (!targetDir.exists()) {
            targetDir.mkpath(".");
        }
        QDir sourceDir(srcFilePath);
        QStringList fileNames = sourceDir.entryList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot);
        for (const QString &fileName : fileNames) {
            const QString newSrc = srcFilePath + "/" + fileName;
            const QString newTgt = tgtFilePath + "/" + fileName;
            if (!copyRecursively(newSrc, newTgt)) return false;
        }
    } else {
        if (QFile::exists(tgtFilePath)) {
            QFile::remove(tgtFilePath);
        }
        if (!QFile::copy(srcFilePath, tgtFilePath)) return false;
    }
    return true;
}
