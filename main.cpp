#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QProcess>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QQmlContext>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include "videoserver.h"        //服务器c++文件
#include "databaseuser.h"
#include "vedio.h"
#include "user.h"
#include "controllers/eventController.h"
#include "clienthandler.h"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // 初始化单例
    EventController::init(&app); // 设置 app 作为父对象
    QString port = "3000";

    // 创建并启动服务器
    VideoServer server;
    bool ok;
    quint16 portNumber = port.toUShort(&ok);

    if (ok && server.startServer(portNumber)) {
        qInfo() << "✅ 视频服务器成功启动：" << portNumber;
    } else {
        qCritical() << "❌ 视频服务器启动失败：" << port;
        return 1;
    }

    // 使用单例模式获取数据库实例
    DatabaseUser *db = DatabaseUser::instance();
    db->loadFromDatabase();

    ClientHandler *clientHandler = new ClientHandler();
    engine.rootContext()->setContextProperty("clientHandler", clientHandler);


    //暴露给qml文件
    engine.rootContext()->setContextProperty("databaseUser", db);
    engine.rootContext()->setContextProperty("eventController", EventController::instance());
    engine.loadFromModule("bili", "Main");

    return app.exec();
}
