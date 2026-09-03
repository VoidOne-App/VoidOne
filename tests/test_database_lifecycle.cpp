#include <QtTest>
#include <QStandardPaths>

#include "Database.h"

class DatabaseLifecycleTests final : public QObject {
    Q_OBJECT

private slots:
    void shutdownIsIdempotent();
    void initializeAfterShutdown();
};

void DatabaseLifecycleTests::shutdownIsIdempotent()
{
    QStandardPaths::setTestModeEnabled(true);
    QVERIFY(Database::initialize());
    Database::shutdown();
    Database::shutdown();
}

void DatabaseLifecycleTests::initializeAfterShutdown()
{
    QVERIFY(Database::initialize());
    Database::shutdown();
    QVERIFY(Database::initialize());
    Database::shutdown();
}

QTEST_APPLESS_MAIN(DatabaseLifecycleTests)
#include "test_database_lifecycle.moc"
