#include <QCoreApplication>
#include <QCommandLineParser>
#include <QNetworkInterface>
#include <iostream>
#include "serverhandler.h"
#include <QDir>
#include <QPluginLoader>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    //app.addLibraryPath("./plugins");
    //app.addLibraryPath("./sqldrivers");


    // 设置应用程序元数据
    app.setApplicationName("AppSocket Server");
    app.setApplicationVersion("1.0");

    // 命令行解析
    QCommandLineParser parser;
    parser.setApplicationDescription("AppSocket TCP Server");
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption portOption("p", "Port to listen on", "port", "8080");
    parser.addOption(portOption);

    parser.process(app);

    // 获取端口
    quint16 port = parser.value(portOption).toUShort();

    // 显示网络信息
    std::cout << "Available IPv4 addresses:" << std::endl;
    for (const QNetworkInterface &interface : QNetworkInterface::allInterfaces()) {
        // 跳过回环接口和未启用的接口
        if (interface.flags().testFlag(QNetworkInterface::IsLoopBack)
            || !interface.flags().testFlag(QNetworkInterface::IsUp)) {
            continue;
        }

        for (const QNetworkAddressEntry &entry : interface.addressEntries()) {
            QHostAddress ip = entry.ip();
            if (ip.protocol() == QAbstractSocket::IPv4Protocol) {
                std::cout << "  " << ip.toString().toStdString() << std::endl;
            }
        }
    }

    // 启动服务
    /*ServerHandler server;
    if (server.startServer(port)) {
        std::cout << "Server started on port " << port << std::endl;
        std::cout << "Press Ctrl+C to stop" << std::endl;
        return app.exec();
    } else {
        std::cerr << "Failed to start server" << std::endl;
        return 1;
    }*/

    // 尝试多个端口启动服务器
    ServerHandler server;
    for (quint16 tryPort = port; tryPort < port + 10; ++tryPort) {
        if (server.startServer(tryPort)) {
            std::cout << "Server started successfully on port " << tryPort << std::endl;
            std::cout << "Press Ctrl+C to stop" << std::endl;
            return app.exec();
        } else {
            //std::cout << "Port " << tryPort << " is busy, trying next port..." << std::endl;
        }
    }

    //std::cerr << "Failed to start server on any port from " << port << " to " << (port + 9) << std::endl;
}
