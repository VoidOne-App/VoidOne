#include <QtTest>
#include <QDir>
#include <QFile>
#include <QTemporaryDir>

#include "SaveBackupManager.h"

class SaveBackupManagerTests final : public QObject {
    Q_OBJECT

private slots:
    void backupAndRestore();
    void rejectsOverlappingDestination();
    void retentionPrunesOldBackups();
};

void SaveBackupManagerTests::backupAndRestore()
{
    QTemporaryDir root;
    QVERIFY(root.isValid());

    const QString saves = root.filePath("saves");
    const QString backups = root.filePath("backups");
    const QString restored = root.filePath("restored");
    QVERIFY(QDir().mkpath(saves));

    QFile file(QDir(saves).filePath("slot1.dat"));
    QVERIFY(file.open(QIODevice::WriteOnly));
    QCOMPARE(file.write("voidone-test"), qint64(12));
    file.close();

    SaveBackupManager manager;
    manager.setMaxBackups(3);
    QVERIFY(manager.createBackup(saves, backups));

    const QString latest = manager.latestBackupPath(backups);
    QVERIFY(!latest.isEmpty());
    QVERIFY(QFile::exists(QDir(latest).filePath("slot1.dat")));

    QVERIFY(manager.restoreBackup(latest, restored));
    QFile restoredFile(QDir(restored).filePath("slot1.dat"));
    QVERIFY(restoredFile.open(QIODevice::ReadOnly));
    QCOMPARE(restoredFile.readAll(), QByteArray("voidone-test"));
}

void SaveBackupManagerTests::rejectsOverlappingDestination()
{
    QTemporaryDir root;
    QVERIFY(root.isValid());
    const QString saves = root.filePath("saves");
    QVERIFY(QDir().mkpath(QDir(saves).filePath("nested")));

    QFile file(QDir(saves).filePath("save.dat"));
    QVERIFY(file.open(QIODevice::WriteOnly));
    QVERIFY(file.write("data") > 0);
    file.close();

    SaveBackupManager manager;
    QVERIFY(!manager.createBackup(saves, QDir(saves).filePath("nested/backups")));
}

void SaveBackupManagerTests::retentionPrunesOldBackups()
{
    QTemporaryDir root;
    QVERIFY(root.isValid());
    const QString saves = root.filePath("saves");
    const QString backups = root.filePath("backups");
    QVERIFY(QDir().mkpath(saves));

    QFile file(QDir(saves).filePath("save.dat"));
    QVERIFY(file.open(QIODevice::WriteOnly));
    QVERIFY(file.write("data") > 0);
    file.close();

    SaveBackupManager manager;
    manager.setMaxBackups(2);
    for (int i = 0; i < 4; ++i) {
        QVERIFY(manager.createBackup(saves, backups));
        QTest::qWait(2);
    }

    const int backupCount = QDir(backups).entryList(
        {"autosave_*"}, QDir::Dirs | QDir::NoDotAndDotDot).size();
    QCOMPARE(backupCount, 2);
}

QTEST_APPLESS_MAIN(SaveBackupManagerTests)
#include "test_save_backup_manager.moc"
