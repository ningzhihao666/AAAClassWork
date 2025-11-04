#include "serverhandler.h"
#include <QDebug>
#include <iostream>

ServerHandler::ServerHandler(QObject *parent) : QObject(parent), m_port(0)
{
    m_server = new QTcpServer(this);
    connect(m_server, &QTcpServer::newConnection, this, &ServerHandler::handleNewConnection);
     initDatabase();
}

ServerHandler::~ServerHandler()
{
    stopServer();
}

bool ServerHandler::startServer(quint16 port)
{
    if (m_server->isListening()) {
        std::cerr << "Server is already running" << std::endl;
        return true;
    }

    if (m_server->listen(QHostAddress::Any, port)) {
        m_port = port;
        std::cout << "Server started on port " << port << std::endl;
        emit serverStarted();
        return true;
    } else {
        std::cerr << "Failed to start server: " << m_server->errorString().toStdString() << std::endl;
        return false;
    }
}

void ServerHandler::stopServer()
{
    if (m_server->isListening()) {
        m_server->close();
        std::cout << "Server stopped" << std::endl;

        // 断开所有客户端
        for (auto &client : m_clientMap) {
            client.socket->disconnectFromHost();
            if (client.socket->state() != QAbstractSocket::UnconnectedState) {
                client.socket->waitForDisconnected(1000);
            }
            client.socket->deleteLater();
        }
        m_clientMap.clear();

        emit serverStopped();
    }
}

void ServerHandler::broadcastClientList()
{
    QJsonObject msg;
    msg["type"] = "client_list";
    QJsonArray clients;

    for (auto &clientInfo : m_clientMap) {
        QJsonObject clientObj;
        clientObj["id"] = clientInfo.id;
        clientObj["name"] = clientInfo.name;
        clients.append(clientObj);
    }

    msg["clients"] = clients;
    QJsonDocument doc(msg);
    QByteArray data = doc.toJson();

    for (auto &clientInfo : m_clientMap) {
        clientInfo.socket->write(data);
    }
}

void ServerHandler::sendToClient(const QString &clientId, const QByteArray &data)
{
    if (m_clientMap.contains(clientId)) { m_clientMap[clientId].socket->write(data); }
}

void ServerHandler::handleNewConnection()
{
    QTcpSocket *client = m_server->nextPendingConnection();
    QString clientId = QString("%1:%2").arg(client->peerAddress().toString()).arg(client->peerPort());

    ClientInfo info;
    info.socket = client;
    info.id = clientId;
    info.name = "Unknown";

    m_clientMap[clientId] = info;
    broadcastClientList();

    QString clientInfo = QString("Client connected: %1").arg(clientId);
    std::cout << clientInfo.toStdString() << std::endl;
    emit clientConnected(clientInfo);

    connect(client, &QTcpSocket::disconnected, this, &ServerHandler::handleClientDisconnected);
    connect(client, &QTcpSocket::readyRead, this, &ServerHandler::handleClientData);
    connect(client, &QTcpSocket::errorOccurred, this, [this, client](QAbstractSocket::SocketError error) {
        Q_UNUSED(error)
        std::cerr << "Client error: " << client->errorString().toStdString() << std::endl;
    });
}

void ServerHandler::handleClientDisconnected()
{
    QTcpSocket *client = qobject_cast<QTcpSocket *>(sender());
    if (!client) return;

    QString clientId = QString("%1:%2").arg(client->peerAddress().toString()).arg(client->peerPort());

    if (m_clientMap.contains(clientId)) {
        QString clientInfo = QString("Client disconnected: %1 (%2)").arg(clientId).arg(m_clientMap[clientId].name);
        std::cout << clientInfo.toStdString() << std::endl;

        m_clientMap.remove(clientId);
        broadcastClientList();

        emit clientDisconnected(clientInfo);
    }

    client->deleteLater();
}

void ServerHandler::handleClientData()
{
    QTcpSocket *client = qobject_cast<QTcpSocket *>(sender());
    if (!client) return;

    QByteArray data = client->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);

    if (doc.isNull() || !doc.isObject()) {
        std::cerr << "Received invalid JSON data from client" << std::endl;
        return;
    }

    QJsonObject obj = doc.object();
    QString type = obj["type"].toString();
    QString clientId = QString("%1:%2").arg(client->peerAddress().toString()).arg(client->peerPort());

    if (!m_clientMap.contains(clientId)) {
        std::cerr << "Received data from unknown client: " << clientId.toStdString() << std::endl;
        return;
    }

    if (type == "set_name") {
        QString name = obj["name"].toString();
        if (!name.isEmpty()) {
            m_clientMap[clientId].name = name;
            std::cout << "Client " << clientId.toStdString() << " set name to " << name.toStdString() << std::endl;
            broadcastClientList();
        }
    } else if (type == "message") {
        QString to = obj["to"].toString();
        QString content = obj["content"].toString();
        QString fromName = obj["name"].toString();

        if (m_clientMap.contains(to)) {
            QJsonObject msgObj;
            msgObj["type"] = "message";
            msgObj["from"] = clientId;
            msgObj["name"] = fromName;
            msgObj["content"] = content;

            QJsonDocument msgDoc(msgObj);
            sendToClient(to, msgDoc.toJson());
            //                                    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            //QString to = obj["to"].toString();
            QString content = obj["content"].toString();
            QString fromName = obj["name"].toString();
            // 保存到数据库
            saveMessageToDatabase(fromName, m_clientMap[to].name, content);

            std::cout << "Message from " << fromName.toStdString() << " to " << m_clientMap[to].name.toStdString()
                      << ": " << content.toStdString() << std::endl;
        } else {
            std::cerr << "Attempt to send message to unknown client: " << to.toStdString() << std::endl;
        }
    } else if (type == "request_history") {//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // 处理客户端请求历史记录
        QString contactName = obj["contact"].toString();
        QString currentClientName = m_clientMap[clientId].name;

        // 从数据库查询聊天历史
        QSqlQuery query;
        query.prepare("SELECT sender_name, receiver_name, content, timestamp "
                      "FROM messages "
                      "WHERE (sender_name = ? AND receiver_name = ?) OR (sender_name = ? AND receiver_name = ?) "
                      "ORDER BY timestamp ASC");
        query.addBindValue(currentClientName);
        query.addBindValue(contactName);
        query.addBindValue(contactName);
        query.addBindValue(currentClientName);

        if (query.exec()) {
            QJsonArray historyArray;
            while (query.next()) {
                QJsonObject msgObj;
                msgObj["sender_name"] = query.value("sender_name").toString();
                msgObj["receiver_name"] = query.value("receiver_name").toString();
                msgObj["content"] = query.value("content").toString();
                msgObj["timestamp"] = query.value("timestamp").toString();
                historyArray.append(msgObj);
            }

            // 发送历史记录给客户端
            QJsonObject responseObj;
            responseObj["type"] = "chat_history";
            responseObj["contact"] = contactName;
            responseObj["history"] = historyArray;

            QJsonDocument doc(responseObj);
            sendToClient(clientId, doc.toJson());

            std::cout << "Sent chat history to " << currentClientName.toStdString()
                      << " for contact " << contactName.toStdString()
                      << " (" << historyArray.size() << " messages)" << std::endl;
        } else {
            std::cerr << "Failed to query chat history: " << query.lastError().text().toStdString() << std::endl;
        }
    }
}

void ServerHandler::initDatabase()
{
    m_db = QSqlDatabase::addDatabase("QMYSQL");
    m_db.setHostName("cq-cdb-6k0yhvtf.sql.tencentcdb.com");
    m_db.setDatabaseName("message");
    m_db.setUserName("root");
    m_db.setPassword("12345678n");
    m_db.setPort(23082);

    if (!m_db.open()) {
        std::cerr << "Database connection failed: " << m_db.lastError().text().toStdString() << std::endl;
        //return false;
    }

    // 创建消息表
    QSqlQuery query;
    query.exec("CREATE TABLE IF NOT EXISTS messages ("
               "id BIGINT AUTO_INCREMENT PRIMARY KEY,"
               "sender_name VARCHAR(255) NOT NULL,"
               "receiver_name VARCHAR(255) NOT NULL,"
               "content TEXT NOT NULL,"
               "timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,"
               "client_sender_id VARCHAR(255)"
               ")");

    std::cout << "Database initialized successfully" << std::endl;
    //return true;
}

void ServerHandler::saveMessageToDatabase(const QString &from, const QString &to, const QString &content)
{
    QSqlQuery query;
    query.prepare("INSERT INTO messages (sender_name, receiver_name, content) VALUES (?, ?, ?)");
    query.addBindValue(from);
    query.addBindValue(to);
    query.addBindValue(content);

    if (!query.exec()) {
        std::cerr << "Failed to save message to database: " << query.lastError().text().toStdString() << std::endl;
    }
}


