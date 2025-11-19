
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QProcess>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QQmlContext>
#include "databaseuser.h"
#include "vedio.h"
#include "user.h"
#include "controllers/eventController.h"
#include"clienthandler.h"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // 初始化单例
    EventController::init(&app); // 设置 app 作为父对象

    //启动 Node.js 服务器
    QProcess *nodeProcess = new QProcess(&app);
    QProcess *nodeProcess2 = new QProcess(&app);

    //获得当前文件夹的绝对地址
    QString exeDir = QCoreApplication::applicationDirPath();
    QStringList pathParts = exeDir.split('/', Qt::SkipEmptyParts);
    QStringList newParts = pathParts.mid(0, pathParts.size() - 2);
    QString withoutLastTwo = "/" + newParts.join("/");
    QString serverScriptPath = withoutLastTwo + "/Send_videos/server.js";

    //启动
    nodeProcess->start("node", QStringList() << serverScriptPath);

    // 检查是否成功启动
    if (!nodeProcess->waitForStarted(3000)) {
        qDebug() << "启动云服务器失败:" << nodeProcess->errorString();
    } else {
        qDebug() << "[云服务器启动成功]";
    }


    // 退出时终止云服务器和云数据库进程
    QObject::connect(&app, &QGuiApplication::aboutToQuit, [nodeProcess]() {
        if (nodeProcess && nodeProcess->state() == QProcess::Running) {
            qDebug() << "正在关闭云服务器...";
            nodeProcess->terminate();
            if (!nodeProcess->waitForFinished(5000)) { nodeProcess->kill(); }
        }
    });
    QObject::connect(&app, &QGuiApplication::aboutToQuit, [nodeProcess2]() {
        if (nodeProcess2 && nodeProcess2->state() == QProcess::Running) {
            qDebug() << "正在关闭云数据库...";
            nodeProcess2->terminate();
            if (!nodeProcess2->waitForFinished(5000)) { nodeProcess2->kill(); }
        }
    });

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
