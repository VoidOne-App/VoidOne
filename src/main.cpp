#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qDebug() << "[VoidOne] Step 1: Application started";

    QQmlApplicationEngine engine;

    qDebug() << "[VoidOne] Step 2: QML engine created";

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []()
        {
            qCritical() << "[VoidOne] Failed to create QML objects.";
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection
    );

    qDebug() << "[VoidOne] Step 3: Loading QML module...";

    engine.loadFromModule("VoidOne", "Main");

    qDebug() << "[VoidOne] Step 4: QML module load requested";

    if (engine.rootObjects().isEmpty())
    {
        qCritical() << "[VoidOne] Step 5: No root QML objects were created.";
        return -1;
    }

    qDebug() << "[VoidOne] Step 6: QML loaded successfully";
    qDebug() << "[VoidOne] Starting event loop...";

    return app.exec();
}    qDebug() << "Step 6";

    return app.exec();
}
