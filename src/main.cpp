#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []()
        {
            qCritical() << "NeonLauncher: QML object creation failed.";
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection
    );

    engine.loadFromModule("NeonLauncher", "Main");

    if (engine.rootObjects().isEmpty())
    {
        qCritical() << "NeonLauncher: No root QML objects were created.";
        return -1;
    }

    return app.exec();
}
