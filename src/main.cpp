#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qDebug() << "Step 1";

    QQmlApplicationEngine engine;

    qDebug() << "Step 2";

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []()
        {
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection
    );

    qDebug() << "Step 3";

    engine.loadFromModule("NeonLauncher", "Main");

    qDebug() << "Step 4";

    if (engine.rootObjects().isEmpty()) {
        qDebug() << "Step 5";
        return -1;
    }

    qDebug() << "Step 6";

    return app.exec();
}