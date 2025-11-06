#include "clienthandler.h"
#include <QDebug>

ClientHandler::ClientHandler(QObject *parent) : QObject(parent)
{
    m_socket = new QTcpSocket(this);
    m_connectionTimer = new QTimer(this);
    m_connectionTimer->setSingleShot(true);

    connect(m_socket, &QTcpSocket::readyRead, this, &ClientHandler::handleDataReceived);
    connect(m_socket, &QTcpSocket::connected, this, &ClientHandler::handleSocketConnected);
    connect(m_socket, &QTcpSocket::disconnected, this, &ClientHandler::handleSocketDisconnected);
    connect(m_socket, &QTcpSocket::errorOccurred, this, &ClientHandler::handleSocketError);
    connect(m_connectionTimer, &QTimer::timeout, this, &ClientHandler::handleConnectionTimeout);
}

ClientHandler::~ClientHandler()
{
    if (m_connectionTimer) {
        m_connectionTimer->stop();
        delete m_connectionTimer;
    }
}

void ClientHandler::setConnecting(bool connecting)
{
    if (m_connecting != connecting) {
        m_connecting = connecting;
        emit connectingChanged(connecting);
    }
}

void ClientHandler::setName(const QString &name)
{
    if (m_name != name && !name.isEmpty()) {
        m_name = name;
        emit nameChanged(name);

        if (isConnected()) {
            QJsonObject obj;
            obj["type"] = "set_name";
            obj["name"] = name;
            m_socket->write(QJsonDocument(obj).toJson());
        }
    }
}

bool ClientHandler::connectToServer(const QString &host, quint16 port)
{
    if (isConnected()) { disconnectFromServer(); }

    m_lastHost = host;
    m_lastPort = port;
    m_retryCount = 0;

    setConnecting(true);

    m_socket->connectToHost(host, port);

    // 启动连接超时定时器
    m_connectionTimer->start(CONNECTION_TIMEOUT);

    qDebug() << "尝试连接到服务器:" << host << ":" << port;
    return true;
}

void ClientHandler::disconnectFromServer()
{
    m_connectionTimer->stop();
    setConnecting(false);

    if (m_socket && m_socket->state() != QAbstractSocket::UnconnectedState) {
        m_socket->disconnectFromHost();
        if (m_socket->state() != QAbstractSocket::UnconnectedState) { m_socket->waitForDisconnected(1000); }
    }
}

void ClientHandler::handleSocketConnected()
{
    m_connectionTimer->stop();
    setConnecting(false);
    m_retryCount = 0;

    m_serverIp = m_socket->peerAddress().toString();
    m_serverPort = m_socket->peerPort();

    // 发送名称信息
    if (!m_name.isEmpty()) {
        QJsonObject obj;
        obj["type"] = "set_name";
        obj["name"] = m_name;
        m_socket->write(QJsonDocument(obj).toJson());
    }

    emit connected();
    emit newMessage("Connected to server");
    emit serverInfoChanged();
    emit connectionChanged();

    qDebug() << "成功连接到服务器";
}

void ClientHandler::handleSocketDisconnected()
{
    m_connectionTimer->stop();
    setConnecting(false);

    m_clientList.clear();
    m_nameToIdMap.clear();
    emit clientListChanged();
    emit disconnected();
    emit connectionChanged();
    emit newMessage("Disconnected from server");

    qDebug() << "与服务器断开连接";
}

void ClientHandler::handleSocketError(QAbstractSocket::SocketError error)
{
    m_connectionTimer->stop();
    setConnecting(false);

    QString errorMsg;
    QString detailedMsg = m_socket->errorString();

    // 根据错误类型提供更友好的错误信息[6,7](@ref)
    switch (error) {
    case QAbstractSocket::ConnectionRefusedError:
        errorMsg = "连接被拒绝：服务器可能未启动或端口错误";
        break;
    case QAbstractSocket::HostNotFoundError:
        errorMsg = "找不到服务器：请检查IP地址是否正确";
        break;
    case QAbstractSocket::SocketTimeoutError:
        errorMsg = "连接超时：网络延迟或服务器无响应";
        break;
    case QAbstractSocket::NetworkError:
        errorMsg = "网络错误：请检查网络连接";
        break;
    case QAbstractSocket::RemoteHostClosedError:
        errorMsg = "服务器主动关闭了连接";
        break;
    default:
        errorMsg = "连接错误: " + detailedMsg;
    }

    // 发出详细错误信号
    emit connectionError(errorMsg);
    emit newMessage("连接失败: " + errorMsg);

    qDebug() << "连接错误:" << errorMsg << "(" << detailedMsg << ")";

    // 自动重连逻辑
    if (m_retryCount < MAX_RETRIES) { QTimer::singleShot(2000, this, &ClientHandler::attemptReconnection); }
}

void ClientHandler::handleConnectionTimeout()
{
    if (m_connecting) {
        m_socket->abort();
        emit connectionError("连接超时：请检查网络和服务器状态");
        emit newMessage("连接超时：服务器无响应");

        // 自动重连逻辑
        if (m_retryCount < MAX_RETRIES) { QTimer::singleShot(2000, this, &ClientHandler::attemptReconnection); }
    }
}

void ClientHandler::attemptReconnection()
{
    //先检查是否超过最大重试次数
    if (m_retryCount >= MAX_RETRIES) {
        qDebug() << "已达到最大重试次数，停止自动重连";
        m_connectionTimer->stop();
        emit connectionError("无法连接到服务器，请检查网络连接后手动重试");
        return;
    }

    // 每次尝试重连时计数器递增
    m_retryCount++;
    qDebug() << "尝试第" << m_retryCount << "次重连，最多" << MAX_RETRIES << "次";

    // 更新界面状态信息
    emit newMessage(QString("正在尝试第 %1/%2 次重连...").arg(m_retryCount).arg(MAX_RETRIES));

    // 执行重连操作
    if (!m_lastHost.isEmpty() && m_lastPort > 0) {
        setConnecting(true);
        m_socket->connectToHost(m_lastHost, m_lastPort);

        // 重启连接超时定时器
        m_connectionTimer->start(CONNECTION_TIMEOUT);
    }
}

void ClientHandler::reconnect()
{
    m_retryCount = 0;
    if (!m_lastHost.isEmpty() && m_lastPort > 0) {
        emit newMessage("手动重新连接...");
        connectToServer(m_lastHost, m_lastPort);
    }
}

void ClientHandler::handleDataReceived()
{
    QByteArray data = m_socket->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);

    if (doc.isObject()) {
        processJson(doc.object());
    } else {
        addChatMessage("Received: " + QString::fromUtf8(data));
    }
}

void ClientHandler::processJson(const QJsonObject &obj)
{
    QString type = obj["type"].toString();

    if (type == "client_list") {
        QStringList newClientList;
        m_nameToIdMap.clear();

        QJsonArray clients = obj["clients"].toArray();
        for (const auto &client : clients) {
            if (client.isObject()) {
                QJsonObject clientObj = client.toObject();
                QString id = clientObj["id"].toString();
                QString name = clientObj["name"].toString();

                if (!name.isEmpty()) {
                    newClientList.append(name);
                    m_nameToIdMap[name] = id;
                }
            }
        }

        if (m_clientList != newClientList) {
            m_clientList = newClientList;
            emit clientListChanged();
        }
    } else if (type == "message") {
        QString fromName = obj["name"].toString();
        QString content = obj["content"].toString();
        addChatMessage(fromName + ": " + content);
    } else if (type == "chat_history") {
        // 处理服务器返回的聊天历史
        QString contactName = obj["contact"].toString();
        QJsonArray history = obj["history"].toArray();

        QString historyText;
        for (const auto &item : history) {
            if (item.isObject()) {
                QJsonObject msgObj = item.toObject();
                QString timestamp = msgObj["timestamp"].toString();
                QString sender = msgObj["sender_name"].toString();
                QString content = msgObj["content"].toString();

                historyText += timestamp + " " + sender + ": " + content + "\n";
            }
        }

        m_chatHistory = historyText;
        emit chatHistoryChanged();
        emit historyReceived(contactName, historyText);
    }
}

void ClientHandler::sendToClient(const QString &name, const QString &message)
{
    if (!isConnected()) {
        addChatMessage("Not connected to server");
        return;
    }

    QString clientId = getClientIdByName(name);
    if (clientId.isEmpty()) {
        addChatMessage("Client not found: " + name);
        return;
    }

    QJsonObject obj;
    obj["type"] = "message";
    obj["to"] = clientId;
    obj["content"] = message;
    obj["name"] = m_name;

    m_socket->write(QJsonDocument(obj).toJson());
    addChatMessage("You: " + message);
}

QString ClientHandler::getClientIdByName(const QString &name)
{
    return m_nameToIdMap.value(name, "");
}

void ClientHandler::addChatMessage(const QString &message)
{
    /*if (!message.trimmed().isEmpty()) {
        QString timestamp = QDateTime::currentDateTime().toString("[hh:mm:ss] ");
        m_chatHistory += timestamp + message + "\n";
        emit chatHistoryChanged();
    }*/
    QString timestamp = QDateTime::currentDateTime().toString("[hh:mm:ss] ");
    m_chatHistory += timestamp + message + "\n";
    emit chatHistoryChanged();
}

void ClientHandler::setActiveChat(
    const QString &clientName) //原来是id！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
{
    // 清空聊天历史
    m_chatHistory = "";
    emit chatHistoryChanged();
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // 加载与该联系人的历史消息
    if (!clientName.isEmpty()) { loadChatHistory(clientName); }
}

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
void ClientHandler::requestChatHistory(const QString &contactName)
{
    if (!isConnected()) {
        addChatMessage("Not connected to server");
        return;
    }

    QJsonObject obj;
    obj["type"] = "request_history";
    obj["contact"] = contactName;
    m_socket->write(QJsonDocument(obj).toJson());
}

void ClientHandler::loadChatHistory(const QString &contactName)
{
    // 清空当前聊天记录，准备加载历史记录
    m_chatHistory = "";
    emit chatHistoryChanged();

    // 请求服务器发送该联系人的历史记录
    requestChatHistory(contactName);
}
