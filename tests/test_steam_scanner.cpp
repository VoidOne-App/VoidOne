#include <QtTest>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QSignalSpy>
#include <QTemporaryDir>
#include <QFileDevice>

#include "SteamScanner.h"

namespace {
bool writeTextFile(const QString &path, const QByteArray &content)
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return false;
    return file.write(content) == content.size();
}
}

class SteamScannerTests final : public QObject {
    Q_OBJECT

private slots:
    void discoversLibraryAndSelectsGameExecutable();
};

void SteamScannerTests::discoversLibraryAndSelectsGameExecutable()
{
    QTemporaryDir root;
    QVERIFY(root.isValid());

    const QString primary = root.filePath("Steam");
    const QString secondary = root.filePath("SteamLibrary");
    const QString gameDir = QDir(secondary).filePath("steamapps/common/VoidOne Test");
    QVERIFY(QDir().mkpath(gameDir));

    const QString gameExe = QDir(gameDir).filePath("VoidOneTest.exe");
    const QString largeRedist = QDir(gameDir).filePath("vcredist_x64.exe");

    QFile gameFile(gameExe);
    QVERIFY(gameFile.open(QIODevice::WriteOnly));
    QVERIFY(gameFile.write("game") > 0);
    gameFile.close();
#if !defined(Q_OS_WIN)
    QVERIFY(QFile::setPermissions(gameExe, QFileDevice::ReadOwner | QFileDevice::WriteOwner | QFileDevice::ExeOwner));
#endif

    QFile redistFile(largeRedist);
    QVERIFY(redistFile.open(QIODevice::WriteOnly));
    QVERIFY(redistFile.write(QByteArray(4096, 'r')) > 0);
    redistFile.close();

    const QString steamApps = QDir(primary).filePath("steamapps");
    QVERIFY(QDir().mkpath(steamApps));
    const QString libraryVdf =
        QDir(steamApps).filePath("libraryfolders.vdf");
    QVERIFY(writeTextFile(libraryVdf,
        ""libraryfolders"\n"
        "{\n"
        "  "0" { "path" "" + QDir::toNativeSeparators(primary).toUtf8() + "" }\n"
        "  "1" { "path" "" + QDir::toNativeSeparators(secondary).toUtf8() + "" }\n"
        "}\n"));

    const QString manifest = QDir(secondary).filePath("steamapps/appmanifest_123.acf");
    QVERIFY(writeTextFile(manifest,
        ""AppState"\n"
        "{\n"
        "  "appid" "123"\n"
        "  "name" "VoidOne Test"\n"
        "  "installdir" "VoidOne Test"\n"
        "}\n"));

    // The override is a single isolated root here; libraryfolders.vdf exercises
    // secondary-library discovery without touching a real Steam installation.
    qputenv("VOIDONE_STEAM_ROOTS", primary.toUtf8());

    qRegisterMetaType<QVector<GameRecord>>("QVector<GameRecord>");
    SteamScannerWorker worker;
    QSignalSpy spy(&worker, &SteamScannerWorker::scanFinished);

    worker.doScan();

    QCOMPARE(spy.count(), 1);
    const auto games = qvariant_cast<QVector<GameRecord>>(spy.at(0).at(0));
    QCOMPARE(games.size(), 1);
    QCOMPARE(games.first().name, QStringLiteral("VoidOne Test"));
    QCOMPARE(QFileInfo(games.first().exePath).fileName(),
             QStringLiteral("VoidOneTest.exe"));

    qunsetenv("VOIDONE_STEAM_ROOTS");
}

QTEST_GUILESS_MAIN(SteamScannerTests)
#include "test_steam_scanner.moc"
