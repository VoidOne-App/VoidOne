#include <QtTest>
#include <QDateTime>
#include <algorithm>

#include "Database.h"

class DatabaseTests final : public QObject {
    Q_OBJECT

private slots:
    void initializeIsIdempotent();
    void crudAndUpsertPreserveIdentity();
    void batchInsertIsAtomic();
};

void DatabaseTests::initializeIsIdempotent()
{
    QVERIFY(Database::initialize());
    QVERIFY(Database::initialize());
}

void DatabaseTests::crudAndUpsertPreserveIdentity()
{
    QVERIFY(Database::initialize());

    const QString suffix = QDateTime::currentDateTimeUtc().toString("yyyyMMddhhmmsszzz");
    const QString exe = QStringLiteral("test:/voidone/%1.exe").arg(suffix);

    GameRecord game;
    game.name = QStringLiteral("VoidOne Test %1").arg(suffix);
    game.exePath = exe;
    game.platform = QStringLiteral("Test");
    QVERIFY(Database::addGame(game));

    const auto initial = Database::getAllGames();
    auto it = std::find_if(initial.cbegin(), initial.cend(), [&](const GameRecord &record) {
        return record.exePath == exe;
    });
    QVERIFY(it != initial.cend());
    const int id = it->id;
    QVERIFY(id >= 0);

    game.id = 999999;
    game.name += QStringLiteral(" Updated");
    QVERIFY(Database::addGame(game));

    const auto updated = Database::getAllGames();
    it = std::find_if(updated.cbegin(), updated.cend(), [&](const GameRecord &record) {
        return record.exePath == exe;
    });
    QVERIFY(it != updated.cend());
    QCOMPARE(it->id, id);
    QVERIFY(it->name.endsWith(QStringLiteral(" Updated")));

    QVERIFY(Database::removeGame(id));
    QVERIFY(!Database::removeGame(id));
}

void DatabaseTests::batchInsertIsAtomic()
{
    QVERIFY(Database::initialize());
    const QString suffix = QDateTime::currentDateTimeUtc().toString("yyyyMMddhhmmsszzz");

    GameRecord first;
    first.name = QStringLiteral("Batch A %1").arg(suffix);
    first.exePath = QStringLiteral("test:/batch/%1/a.exe").arg(suffix);

    GameRecord second;
    second.name = QStringLiteral("Batch B %1").arg(suffix);
    second.exePath = QStringLiteral("test:/batch/%1/b.exe").arg(suffix);

    QVERIFY(Database::addGamesBatch({first, second}));

    const auto games = Database::getAllGames();
    QVERIFY(std::any_of(games.cbegin(), games.cend(), [&](const GameRecord &g) { return g.exePath == first.exePath; }));
    QVERIFY(std::any_of(games.cbegin(), games.cend(), [&](const GameRecord &g) { return g.exePath == second.exePath; }));
}

QTEST_APPLESS_MAIN(DatabaseTests)
#include "test_database.moc"
