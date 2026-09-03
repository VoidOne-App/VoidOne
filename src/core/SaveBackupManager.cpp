#include "SaveBackupManager.h"

#include <QDateTime>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <algorithm>

namespace {
QString normalizedPath(const QString &input)
{
    if (input.trimmed().isEmpty())
        return {};

    QFileInfo info(input);
    QString absolute = info.absoluteFilePath();
    if (absolute.isEmpty())
        return {};

    // canonicalFilePath() is empty for a non-existent path. Resolve the
    // nearest existing ancestor and append the missing suffix instead.
    const QString canonical = info.canonicalFilePath();
    if (!canonical.isEmpty())
        return QDir::cleanPath(canonical);

    QStringList missing;
    QFileInfo current(info);
    while (!current.exists()) {
        const QString name = current.fileName();
        if (!name.isEmpty())
            missing.prepend(name);
        const QString parent = current.absolutePath();
        if (parent == current.absoluteFilePath())
            break;
        current = QFileInfo(parent);
    }

    QString base = current.canonicalFilePath();
    if (base.isEmpty())
        base = current.absoluteFilePath();

    QDir result(base);
    for (const QString &part : missing)
        result = QDir(result.filePath(part));
    return QDir::cleanPath(result.absolutePath());
}

bool pathsOverlap(const QString &firstPath, const QString &secondPath)
{
    const QString first = normalizedPath(firstPath);
    const QString second = normalizedPath(secondPath);
    if (first.isEmpty() || second.isEmpty())
        return false;

#ifdef Q_OS_WIN
    const Qt::CaseSensitivity sensitivity = Qt::CaseInsensitive;
#else
    const Qt::CaseSensitivity sensitivity = Qt::CaseSensitive;
#endif

    auto components = [](const QString &path) {
        QString normalized = QDir::fromNativeSeparators(QDir::cleanPath(path));
        while (normalized.endsWith('/'))
            normalized.chop(1);
        return normalized.split('/', Qt::SkipEmptyParts);
    };

    const QStringList firstParts = components(first);
    const QStringList secondParts = components(second);

    auto isSameOrChild = [sensitivity](const QStringList &path, const QStringList &parent) {
        if (path.size() < parent.size())
            return false;
        for (qsizetype i = 0; i < parent.size(); ++i) {
            if (path.at(i).compare(parent.at(i), sensitivity) != 0)
                return false;
        }
        return true;
    };

    return isSameOrChild(firstParts, secondParts) || isSameOrChild(secondParts, firstParts);
}
}

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

    if (pathsOverlap(saveDirPath, backupDestinationPath)) {
        emit backupCompleted(false, "Backup destination cannot overlap the save directory. / مسیر بکاپ نمی‌تواند با پوشه سیو هم‌پوشانی داشته باشد.");
        return false;
    }

    QDir destinationRoot(backupDestinationPath);
    if (!destinationRoot.exists() && !destinationRoot.mkpath(".")) {
        emit backupCompleted(false, "Backup destination could not be created. / مسیر بکاپ ساخته نشد.");
        return false;
    }

    const QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss-zzz");
    const QString finalDestPath = destinationRoot.filePath("autosave_" + timestamp);
    if (!QDir().mkpath(finalDestPath)) {
        emit backupCompleted(false, "Backup directory could not be created. / پوشه بکاپ ساخته نشد.");
        return false;
    }

    const bool success = copyRecursively(saveDirPath, finalDestPath);
    if (!success)
        QDir(finalDestPath).removeRecursively();
    else
        pruneOldBackups(backupDestinationPath);

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

    if (pathsOverlap(backupFilePath, targetSaveDirPath)) {
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
    if (!srcInfo.exists() || srcInfo.isSymLink())
        return false;

    if (srcInfo.isDir()) {
        if (pathsOverlap(srcFilePath, tgtFilePath))
            return false;

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
