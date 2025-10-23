#include "Chat_clienthandler.h"
#include <QDebug>

ClientHandler::ClientHandler(QObject *parent)
    : QObject(parent)
    , m_port(0)
    , m_clientId("")
    , m_chatHistory("")
    , m_activeChat("")
    , m_name("saki酱")
{
    m_socket = new QTcpSocket(this);

    connect(m_socket, &QTcpSocket::readyRead, this, &ClientHandler::handleDataReceived);
    connect(m_socket, &QTcpSocket::connected, this, &ClientHandler::handleSocketConnected);
    connect(m_socket, &QTcpSocket::disconnected, this, &ClientHandler::disconnected);
    connect(m_socket, &QTcpSocket::errorOccurred, this, &ClientHandler::handleSocketError);
}

void ClientHandler::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged(name); // 发出名字变化信号
    }

    // 将名字发送到服务器
    if (isConnected()) {
        QJsonObject obj;
        obj["type"] = "set_name";
        obj["name"] = name;

        QJsonDocument doc(obj);
        m_socket->write(doc.toJson());
    }
}

void ClientHandler::setActiveChat(const QString &clientId)
{
    // m_activeChat = clientId;
    m_chatHistory = ""; // 清空聊天历史
    emit chatHistoryChanged();
}

void ClientHandler::handleSocketConnected()
{
    // 生成客户端ID：IP地址:端口
    m_clientId = QString("%1:%2").arg(m_socket->localAddress().toString()).arg(m_socket->localPort());

    m_server_ip = m_socket->peerAddress().toString();

    if (!m_name.isEmpty()) {
        QJsonObject obj;
        obj["type"] = "set_name";
        obj["name"] = m_name;

        QJsonDocument doc(obj);
        m_socket->write(doc.toJson());
    }

    emit connected();
    emit newMessage("已连接到服务器");
    emit serverInfoChanged();
}

bool ClientHandler::connectToServer(const QString &host, quint16 port)
{
    m_port = port;

    if (isConnected()) {
        emit newMessage("客户端已在连接状态");
        return true;
    }

    m_socket->connectToHost(host, port);

    return true;
}

void ClientHandler::disconnectFromServer()
{
    if (isConnected()) { m_socket->disconnectFromHost(); }
}

void ClientHandler::sendMessage(const QString &message)
{
    if (isConnected()) {
        m_socket->write(message.toUtf8());
        emit newMessage("发送消息: " + message);
    } else {
        emit newMessage("未连接服务器，无法发送消息");
    }
}

void ClientHandler::handleDataReceived()
{
    QByteArray data = m_socket->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isObject()) {
        QJsonObject obj = doc.object();
        QString type = obj["type"].toString();

        if (type == "client_list") {
            QJsonArray clients = obj["clients"].toArray();
            QStringList newClientList;

            for (auto client : clients) {
                if (client.isObject()) {
                    QJsonObject clientObj = client.toObject();
                    QString name = clientObj["name"].toString();
                    QString ip = clientObj["id"].toString();
                    if (!name.isEmpty()) {
                        newClientList.append(name);
                        m_nameToIdMap[name] = ip;
                    } else {
                        // 如果没有名字，使用ID
                        newClientList.append(clientObj["id"].toString());
                        m_nameToIdMap[ip] = ip;
                    }
                } else {
                    QString id = client.toString();
                    newClientList.append(id);
                    m_nameToIdMap[id] = id;
                }
            }

            // 更新属性值并发出信号
            if (m_clientList != newClientList) {
                m_clientList = newClientList;
                emit clientListChanged();
            }
        } else if (type == "message") {
            QString from = obj["from"].toString();
            QString content = obj["content"].toString();
            QString name = obj["name"].toString();

            // 添加消息到历史
            addChatMessage(name + ": " + content);
        }
    } else {
        addChatMessage("收到服务器消息: " + QString::fromUtf8(data));
    }
}

// 通过名字获取客户端ID
QString ClientHandler::getClientIdByName(const QString &name)
{
    return m_nameToIdMap.value(name, "");
}

void ClientHandler::sendToClient(const QString &name, const QString &message)
{
    if (!isConnected()) {
        addChatMessage("未连接服务器，无法发送消息");
        return;
    }

    QString clientId = getClientIdByName(name);
    if (clientId.isEmpty()) {
        addChatMessage("找不到目标客户端: " + name);
        return;
    }

    QJsonObject obj;
    obj["type"] = "message";
    obj["to"] = clientId;
    obj["content"] = message;
    obj["from"] = m_clientId;
    obj["name"] = m_name;

    QJsonDocument doc(obj);
    m_socket->write(doc.toJson());

    // 添加发送的消息到历史
    addChatMessage("我: " + message);
}

void ClientHandler::handleSocketError(QAbstractSocket::SocketError error)
{
    Q_UNUSED(error)
    emit newMessage("连接错误: " + m_socket->errorString());
}

void ClientHandler::addChatMessage(const QString &message)
{
    QString timestamp = QDateTime::currentDateTime().toString("[hh:mm:ss] ");
    m_chatHistory += timestamp + message + "\n";
    emit chatHistoryChanged();
    emit newMessage(message); // 可选：记录日志
}
