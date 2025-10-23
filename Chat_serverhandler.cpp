#include "Chat_serverhandler.h"
#include <QHostInfo>
#include <QNetworkInterface>
#include <QDebug>
#include <iostream>

ServerHandler::ServerHandler(QObject *parent) : QObject(parent), m_port(0)
{
    m_server = new QTcpServer(this);
    connect(m_server, &QTcpServer::newConnection, this, &ServerHandler::handleNewConnection);
}

void ServerHandler::broadcastClientList()
{
    QJsonObject msg;
    msg["type"] = "client_list";
    QJsonArray clients;
    for (auto &clientInfo : m_clientMap) {
        QJsonObject clientObj;
        clientObj["id"] = clientInfo.id;     // 客户端ID（IP:端口）
        clientObj["name"] = clientInfo.name; // 客户端名字
        clients.append(clientObj);
    }

    msg["clients"] = clients;

    QJsonDocument doc(msg);
    for (auto &info : m_clientMap) {
        info.socket->write(doc.toJson());
    }
}

bool ServerHandler::startServer(quint16 port)
{
    m_port = port;

    if (m_server->isListening()) {
        emit newMessage("服务器已在运行");

        return true;
    }

    QHostAddress serverAddress("49.232.73.239");
    if (serverAddress.isNull()) {
        emit newMessage("无效的 IP 地址: 49.232.73.239");
        std::cout << "error" << std::endl;
        return false;
    }

    // 尝试在腾讯云 IP 地址上监听
    if (m_server->listen(serverAddress, port)) {
        emit newMessage("腾讯云服务器启动成功");
        emit serverStarted();
        m_ip = "49.232.73.239";
        emit ipChanged();
        emit serverStarted();
        emit newMessage("服务器启动成功");
        return true;
    }

    // 腾讯云 IP 监听失败，尝试监听所有地址
    if (m_server->listen(QHostAddress::Any, port)) {
        // 获取实际监听的地址和端口
        QHostAddress actualAddress = m_server->serverAddress();
        quint16 actualPort = m_server->serverPort();

        // 获取所有可用的 IPv4 地址
        QString ipAddresses;
        foreach (const QHostAddress &address, QNetworkInterface::allAddresses()) {
            if (address.protocol() == QAbstractSocket::IPv4Protocol && address != QHostAddress::LocalHost) {
                ipAddresses.append(address.toString());
            }
        }

        // 格式化地址信息
        QString addressInfo;
        if (ipAddresses.isEmpty()) {
            addressInfo = "无可用 IP 地址";
        } else {
            addressInfo = "可用 IP 地址: " + ipAddresses;
        }

        // 发送消息
        emit newMessage("服务器启动成功（监听所有地址）");
        emit newMessage("监听端口: " + QString::number(actualPort));
        emit newMessage(addressInfo);

        // 更新 IP 属性
        m_ip = ipAddresses;
        std::cout << m_ip.toStdString() << std::endl;
        emit ipChanged();

        emit serverStarted();
        return true;
    }

    emit newMessage("服务器启动失败");
    return false;
}

void ServerHandler::stopServer()
{
    if (m_server->isListening()) {
        m_server->close();
        emit serverStopped();
        emit newMessage("服务器已停止");
    }

    for (QTcpSocket *client : m_clients) {
        client->disconnectFromHost();
        if (client->state() != QAbstractSocket::UnconnectedState) { client->waitForDisconnected(); }
        client->deleteLater();
    }
    m_clients.clear();
}

void ServerHandler::sendToAll(const QString &message)
{
    for (QTcpSocket *client : m_clients) {
        if (client->state() == QAbstractSocket::ConnectedState) { client->write(message.toUtf8()); }
    }
}

QStringList ServerHandler::clientIps() const
{
    QStringList ips;
    for (QTcpSocket *client : m_clients) {
        ips.append(client->peerAddress().toString());
    }
    return ips;
}

void ServerHandler::handleNewConnection()
{
    QTcpSocket *client = m_server->nextPendingConnection();
    QString clientId = QString("%1:%2").arg(client->peerAddress().toString()).arg(client->peerPort());

    m_clients.append(client);

    ClientInfo info;
    info.socket = client;
    info.id = clientId;
    info.name = "";

    m_clientMap[clientId] = info; // 存储映射
    broadcastClientList();        // 广播更新

    QString clientInfo = QString("客户端连接: %1:%2").arg(client->peerAddress().toString()).arg(client->peerPort());

    emit clientConnected(clientInfo);
    emit newMessage(clientInfo);

    connect(client, &QTcpSocket::disconnected, this, &ServerHandler::handleClientDisconnected);
    connect(client, &QTcpSocket::readyRead, this, &ServerHandler::handleClientData);
    connect(client, &QTcpSocket::errorOccurred, this, [this, client](QAbstractSocket::SocketError error) {
        Q_UNUSED(error)
        emit newMessage("客户端错误: " + client->errorString());
    });
}

void ServerHandler::handleClientDisconnected()
{
    QTcpSocket *client = qobject_cast<QTcpSocket *>(sender());
    if (!client) return;

    QString clientId = client->objectName();
    m_clientMap.remove(clientId); //移除映射表
    broadcastClientList();        //广播更新

    QString clientInfo = QString("客户端断开: %1:%2").arg(client->peerAddress().toString()).arg(client->peerPort());

    m_clients.removeOne(client);
    client->deleteLater();

    emit clientDisconnected(clientInfo);
    emit newMessage(clientInfo);
}

void ServerHandler::handleClientData()
{
    QTcpSocket *client = qobject_cast<QTcpSocket *>(sender());
    if (!client) return;

    QByteArray data = client->readAll(); // 一次性读取所有数据
    QString message = QString::fromUtf8(data);
    emit newMessage("收到客户端消息: " + message);

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isObject()) {
        QJsonObject obj = doc.object();
        QString type = obj["type"].toString();

        if (type == "message") {
            QString to = obj["to"].toString();
            if (m_clientMap.contains(to)) {
                m_clientMap[to].socket->write(data); // 直接转发
            }
        } else if (type == "set_name") {
            QString name = obj["name"].toString();
            QString clientId = QString("%1:%2").arg(client->peerAddress().toString()).arg(client->peerPort());

            if (m_clientMap.contains(clientId)) {
                m_clientMap[clientId].name = name;
                broadcastClientList(); // 更新客户端列表
            }
        }
    }
}
