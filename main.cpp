#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "databaseuser.h"
#include "Chat_messagehandler.h"
#include "videomanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    DatabaseUser db;
    QQmlApplicationEngine engine;

    MessageHandler *msgHandler = new MessageHandler(&engine);
    engine.rootContext()->setContextProperty("msgHandler", msgHandler);
    VideoManager videoManager;
    engine.rootContext()->setContextProperty("videoManager", &videoManager); //TODO

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("bili", "Main");

    return app.exec();
}
