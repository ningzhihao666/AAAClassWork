#include "Chat_messagehandler.h"
#include <QHostInfo>
#include <QNetworkInterface>
#include <QDebug>

MessageHandler::MessageHandler(QObject *parent) : QObject(parent)
{
    connect(&m_serverHandler, &ServerHandler::newMessage, this, &MessageHandler::addMessage); //处理服务端消息
    connect(&m_serverHandler, &ServerHandler::clientConnected, this, [this](const QString &info) {
        addMessage(info);
        emit clientCountChanged();
    }); //处理客户端连接的情况
    connect(&m_serverHandler, &ServerHandler::clientDisconnected, this, [this](const QString &info) {
        addMessage(info);
        emit clientCountChanged();
    }); //处理客户端断开连接的情况
    connect(&m_serverHandler, &ServerHandler::serverStarted, this, [this]() {
        updateHostInfo();
        emit serverInfoChanged();
    }); //处理服务端开启情况
    connect(&m_serverHandler, &ServerHandler::serverStopped, this, [this]() {
        emit clientCountChanged();
        emit serverInfoChanged();
    }); //处理服务端暂停

    connect(&m_clientHandler, &ClientHandler::newMessage, this, &MessageHandler::addMessage);
    //处理客户端消息
    connect(&m_clientHandler, &ClientHandler::connected, this, [this]() { addMessage("已连接到服务器"); });
    //处理客户端连接
    connect(&m_clientHandler, &ClientHandler::disconnected, this, [this]() { addMessage("与服务器断开连接"); });
    //处理客户端断开连接

    updateHostInfo();
}

void MessageHandler::addMessage(const QString &msg)
{
    m_message = msg;
    emit messageChanged();
}

void MessageHandler::startServer()
{
    m_serverHandler.startServer();
} //启动服务端

void MessageHandler::stopServer()
{
    m_serverHandler.stopServer();
}

void MessageHandler::startClient()
{
    m_clientHandler.connectToServer("10.253.88.107");
}

void MessageHandler::sendToServer(const QString &message)
{
    m_clientHandler.sendMessage(message);
}

void MessageHandler::sendToClients(const QString &message)
{
    m_serverHandler.sendToAll(message);
}

void MessageHandler::updateHostInfo()
{
    m_hostname = QHostInfo::localHostName();
    m_ipAddresses.clear();
    foreach (const QHostAddress &address, QNetworkInterface::allAddresses()) {
        if (address.protocol() == QAbstractSocket::IPv4Protocol && address != QHostAddress::LocalHost) {
            m_ipAddresses.append(address.toString());
        }
    }
}
