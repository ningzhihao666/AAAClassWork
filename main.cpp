#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QProcess>
#include <QDebug>
#include <QDir>
#include <QFile>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // 创建 QProcess 实例来启动 Node.js 服务器
    QProcess *nodeProcess = new QProcess(&app);

    // 连接信号以捕获进程输出
    QObject::connect(nodeProcess, &QProcess::readyReadStandardOutput, [nodeProcess]() {
        qDebug() << "Node.js输出:" << nodeProcess->readAllStandardOutput();
    });
    QObject::connect(nodeProcess, &QProcess::readyReadStandardError, [nodeProcess]() {
        qDebug() << "Node.js错误:" << nodeProcess->readAllStandardError();
    });

    // 设置服务器路径
    QString serverScriptPath = "/root/B站/AAAClassWork/Send_videos/server.js";

    qDebug() << "找到服务器文件:" << serverScriptPath;
    qDebug() << "启动Node.js服务器...";

    // 启动Node.js服务器
    nodeProcess->start("node", QStringList() << serverScriptPath);

    // 检查进程是否成功启动
    if (!nodeProcess->waitForStarted(3000)) {
        qDebug() << "启动Node.js服务器失败:" << nodeProcess->errorString();
    } else {
        //当服务器成功启动是加载主程序
        qDebug() << "Node.js服务器启动成功";
        engine.loadFromModule("bili", "Main");
    }

    // 应用程序退出时终止Node.js进程
    QObject::connect(&app, &QGuiApplication::aboutToQuit, [nodeProcess]() {
        if (nodeProcess && nodeProcess->state() == QProcess::Running) {
            qDebug() << "正在关闭Node.js服务器...";
            nodeProcess->terminate();
            if (!nodeProcess->waitForFinished(5000)) {
                nodeProcess->kill();
            }
        }
    });

    return app.exec();
}
