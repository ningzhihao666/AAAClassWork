#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QProcess>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QQmlContext>
#include "databaseuser.h"
#include "controllers/eventController.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    //启动 Node.js 服务器
    QProcess *nodeProcess = new QProcess(&app);
    QProcess *nodeProcess2 = new QProcess(&app);

    //获得当前文件夹的绝对地址
    QString exeDir = QCoreApplication::applicationDirPath();
    QStringList pathParts = exeDir.split('/', Qt::SkipEmptyParts);
    QStringList newParts = pathParts.mid(0, pathParts.size() - 2);
    QString withoutLastTwo = "/" + newParts.join("/");
    QString serverScriptPath = withoutLastTwo+"/Send_videos/server.js";
    QString dbScriptPath = withoutLastTwo+"/db.js";

    //启动
    nodeProcess->start("node", QStringList() << serverScriptPath);
    nodeProcess2->start("node", QStringList() << dbScriptPath);

    // 检查是否成功启动
    if (!nodeProcess->waitForStarted(3000)) {
        qDebug() << "启动云服务器失败:" << nodeProcess->errorString();
    } else {
        qDebug() << "[云服务器启动成功]";
        // 检查是否成功启动
        if (!nodeProcess2->waitForStarted(3000)) {
            qDebug() << "[云数据库启动失败]:" << nodeProcess->errorString();
        } else {
            qDebug() << "[云数据库启动成功]";
        }
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
    int panduan = 1;

    // 初始化数据库（通过 API）
    while (panduan) {
        if (db->initDatabase()) {
            panduan = 0;
            qDebug() << "✅ 数据库初始化成功！";


            // 加载用户数据
            if (db->loadFromDatabase()) {
                qDebug() << "✅ 用户数据加载成功！";

                // 测试添加用户和删除
                //User *testUser = new User("nickname测试用户", "account123", "password123");
                //db->AddNetizen(testUser);

                /*User *testUser1 = new User("nickname测试用", "account12", "password12");
             db->AddNetizen(testUser1);
             //db->RemoveNetizen("account123");*/

            } else {
                qDebug() << "❌ 用户数据加载失败！";
            }
        } else {
            panduan = 0;
            qDebug() << "❌ 数据库初始化失败！";
            qDebug() << "请确保 Node.js API 服务器正在运行: node db.js";
        }
    }


    //暴露给qml文件
    engine.rootContext()->setContextProperty("databaseUser", db);

    EventController eventController;
    engine.rootContext()->setContextProperty("eventController", &eventController);


    engine.loadFromModule("bili", "Main");

    return app.exec();
}
