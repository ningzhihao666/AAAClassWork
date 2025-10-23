#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include "databaseuser.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 使用单例模式获取数据库实例
    DatabaseUser* db = DatabaseUser::instance();

    // 初始化数据库（通过 API）
    if (db->initDatabase()) {
        qDebug() << "✅ 数据库初始化成功！";

        // 加载用户数据
        if (db->loadFromDatabase()) {
            qDebug() << "✅ 用户数据加载成功！";

            // 测试添加用户
            /*User *testUser = new User("nickname测试用户", "account123", "password123");
             db->AddNetizen(testUser);

             User *testUser1 = new User("nickname测试用", "account12", "password12");
             db->AddNetizen(testUser1);
             //db->RemoveNetizen("account123");*/

        } else {
            qDebug() << "❌ 用户数据加载失败！";
        }
    } else {
        qDebug() << "❌ 数据库初始化失败！";
        qDebug() << "请确保 Node.js API 服务器正在运行: node db.js";
    }

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

