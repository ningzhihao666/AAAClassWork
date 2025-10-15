#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "databaseuser.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    DatabaseUser db;
    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("bili", "Main");

    return app.exec();
}
