#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "src/presentation/videoController.h"
#include "src/component/clienthandler.h"
#include "src/presentation/userController.h"

#include "src/component/simpleuploader.h"
#include "src/component/videouploader.h"
#include <QDebug>
#include <QDateTime>
#include <QRandomGenerator>
#include <QFile>
#include <QTextStream>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QEventLoop>
#include <QTimer>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    VideoUploader* videoUploader = new VideoUploader(&app);

    auto videoController = interface::VideoController::instance();
    auto userController = interface::UserController::instance();

    qmlRegisterType<interface::VideoController>("VideoApp", 1, 0, "VideoController");
    qmlRegisterType<interface::UserController>("UserApp", 1, 0, "UserController");

    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/Bilibili/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    ClientHandler *clientHandler = new ClientHandler();

    engine.rootContext()->setContextProperty("videoUploader", videoUploader);
    engine.rootContext()->setContextProperty("clientHandler", clientHandler);
    engine.rootContext()->setContextProperty("videoController", videoController);
    engine.rootContext()->setContextProperty("userController", userController);

    database::VideoDatabase& db = database::VideoDatabase::getInstance();
    db.connectToDatabase(
        "cq-cdb-n6tlcxx5.sql.tencentcdb.com",  // 主机
        20450,                                  // 端口
        "video",                                // 数据库名
        "root",                                 // 用户名
        "12345678lzh"                             // 密码
        );

    engine.load(url);

    // 程序退出时销毁单例
    QObject::connect(&app, &QGuiApplication::aboutToQuit, []() {
        interface::VideoController::destroyInstance();
        interface::UserController::destroyInstance();
        infrastructure::UserRepository::destroy();  // 销毁数据库连接
    });

    return app.exec();
}
