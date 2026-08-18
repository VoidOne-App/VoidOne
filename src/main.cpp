#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QMessageBox>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        [&app]()
        {
            QMessageBox::critical(
                nullptr,
                "NeonLauncher",
                "Failed to load the QML interface."
            );

            app.exit(-1);
        },
        Qt::QueuedConnection
    );

    engine.loadFromModule("NeonLauncher", "Main");

    if (engine.rootObjects().isEmpty())
    {
        QMessageBox::critical(
            nullptr,
            "NeonLauncher",
            "No QML root object was created."
        );

        return -1;
    }

    return app.exec();
}
