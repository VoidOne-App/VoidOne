#include "SaveBackupManager.h"

#include <QDateTime>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QSet>
#include <algorithm>

SaveBackupManager::SaveBackupManager(QObject *parent)
    : QObject(parent), m_autoSaveTimer(new QTimer(this))
{
    connect(m_autoSaveTimer, &QTimer::timeout, this, &SaveBackupManager::performAutoSave);
}

bool SaveBackupManager::createBackup(const QString &saveDirPath, const QString &backupDestinationPath)
{
    const QDir sourceDir(saveDirPath);
    if (!sourceDir.exists()) {
        emit backupCompleted(false, "Save directory does not exist! / پوشه سیو وجود ندارد!");
        return false;
    }

    QDir destinationRoot(backupDestinationPath);
    if (!destinationRoot.exists() && !destinationRoot.mkpath(".")) {
        emit backupCompleted(false, "Backup destination could not be created. / مسیر بکاپ ساخته نشد.");
        return false;
    }

    const QString sourceCanonical = QFileInfo(saveDirPath).canonicalFilePath();
    const QString destinationCanonical = destinationRoot.canonicalPath();
    if (!sourceCanonical.isEmpty() && !destinationCanonical.isEmpty()) {
        if (destinationCanonical == sourceCanonical ||
            destinationCanonical.startsWith(sourceCanonical + QDir::separator())) {
            emit backupCompleted(false, "Backup destination cannot be inside the save directory. / مسیر بکاپ نمی‌تواند داخل پوشه سیو باشد.");
            return false;
        }
    }

    // Include milliseconds so repeated backups cannot collide within one second.
    const QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss-zzz");
    const QString finalDestPath = destinationRoot.filePath("autosave_" + timestamp);
    if (!QDir().mkpath(finalDestPath)) {
        emit backupCompleted(false, "Backup directory could not be created. / پوشه بکاپ ساخته نشد.");
        return false;
    }

    const bool success = copyRecursively(saveDirPath, finalDestPath);
    if (!success) {
        QDir(finalDestPath).removeRecursively();
    } else {
        pruneOldBackups(backupDestinationPath);
    }

    emit backupCompleted(
        success,
        success ? "Backup created successfully! / پشتیبان‌گیری با موفقیت انجام شد!"
                : "Failed to create backup. / خطا در پشتیبان‌گیری.");
    return success;
}

QString SaveBackupManager::latestBackupPath(const QString &backupDestinationPath)
{
    const QDir destDir(backupDestinationPath);
    if (!destDir.exists())
        return {};

    const QStringList entries = destDir.entryList(
        {"autosave_*"}, QDir::Dirs | QDir::NoDotAndDotDot, QDir::Time);
    return entries.isEmpty() ? QString() : destDir.absoluteFilePath(entries.constFirst());
}

bool SaveBackupManager::restoreBackup(const QString &backupFilePath, const QString &targetSaveDirPath)
{
    const QFileInfo backupInfo(backupFilePath);
    if (!backupInfo.isDir()) {
        emit backupCompleted(false, "Backup directory does not exist. / پوشه بکاپ وجود ندارد.");
        return false;
    }

    const QString backupCanonical = backupInfo.canonicalFilePath();
    const QString targetCanonical = QFileInfo(targetSaveDirPath).canonicalFilePath();
    if (!backupCanonical.isEmpty() && !targetCanonical.isEmpty() &&
        (backupCanonical == targetCanonical ||
         backupCanonical.startsWith(targetCanonical + QDir::separator()))) {
        emit backupCompleted(false, "Restore source and target overlap. / مبدا و مقصد ریستور هم‌پوشانی دارند.");
        return false;
    }

    QDir targetDir(targetSaveDirPath);
    if (!targetDir.exists() && !targetDir.mkpath(".")) {
        emit backupCompleted(false, "Target save directory could not be created. / پوشه مقصد ساخته نشد.");
        return false;
    }

    const bool success = copyRecursively(backupFilePath, targetSaveDirPath);
    emit backupCompleted(
        success,
        success ? "Backup restored successfully! / بازگردانی بکاپ با موفقیت انجام شد!"
                : "Failed to restore backup. / خطا در بازگردانی بکاپ.");
    return success;
}

void SaveBackupManager::setAutoSaveEnabled(bool enabled)
{
    if (m_autoSaveEnabled == enabled)
        return;

    m_autoSaveEnabled = enabled;
    if (enabled)
        m_autoSaveTimer->start(m_intervalSeconds * 1000);
    else
        m_autoSaveTimer->stop();
    emit autoSaveEnabledChanged(m_autoSaveEnabled);
}

void SaveBackupManager::setAutoSaveIntervalSeconds(int seconds)
{
    if (seconds <= 0 || m_intervalSeconds == seconds)
        return;

    m_intervalSeconds = seconds;
    if (m_autoSaveEnabled)
        m_autoSaveTimer->start(m_intervalSeconds * 1000);
    emit autoSaveIntervalChanged(m_intervalSeconds);
}

void SaveBackupManager::setMaxBackups(int count)
{
    const int bounded = std::clamp(count, 1, 1000);
    if (m_maxBackups == bounded)
        return;

    m_maxBackups = bounded;
    if (!m_destinationDir.isEmpty())
        pruneOldBackups(m_destinationDir);
    emit maxBackupsChanged(m_maxBackups);
}

void SaveBackupManager::configureAutoSave(const QString &saveDirPath, const QString &backupDestinationPath)
{
    m_targetSaveDir = saveDirPath;
    m_destinationDir = backupDestinationPath;
}

void SaveBackupManager::performAutoSave()
{
    if (m_targetSaveDir.isEmpty() || m_destinationDir.isEmpty())
        return;
    createBackup(m_targetSaveDir, m_destinationDir);
}

void SaveBackupManager::pruneOldBackups(const QString &backupDestinationPath) const
{
    QDir destination(backupDestinationPath);
    if (!destination.exists())
        return;

    QStringList entries = destination.entryList(
        {"autosave_*"}, QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);
    std::sort(entries.begin(), entries.end(), std::greater<QString>());

    for (int i = m_maxBackups; i < entries.size(); ++i) {
        QDir oldBackup(destination.filePath(entries.at(i)));
        if (!oldBackup.removeRecursively())
            qWarning() << "[Backup] Failed to prune old backup:" << oldBackup.absolutePath();
    }
}

bool SaveBackupManager::copyRecursively(const QString &srcFilePath, const QString &tgtFilePath)
{
    const QFileInfo srcInfo(srcFilePath);
    if (!srcInfo.exists())
        return false;

    if (srcInfo.isSymLink()) {
        // Do not follow arbitrary symlinks/reparse points during a backup.
        return false;
    }

    if (srcInfo.isDir()) {
        QDir targetDir(tgtFilePath);
        if (!targetDir.exists() && !targetDir.mkpath("."))
            return false;

        const QDir sourceDir(srcFilePath);
        const QFileInfoList entries = sourceDir.entryInfoList(
            QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot,
            QDir::Name);
        for (const QFileInfo &entry : entries) {
            if (!copyRecursively(entry.absoluteFilePath(), targetDir.filePath(entry.fileName())))
                return false;
        }
        return true;
    }

    if (QFile::exists(tgtFilePath) && !QFile::remove(tgtFilePath))
        return false;
    return QFile::copy(srcFilePath, tgtFilePath);
}
