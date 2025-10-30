#pragma once

#include <QTcpServer>
#include <QTcpSocket>
#include <QObject>
#include <QList>
#include <QMap>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

struct ClientInfo
{
    QTcpSocket *socket;
    QString id;
    QString name;
};

class ServerHandler : public QObject
{
    Q_OBJECT
public:
    explicit ServerHandler(QObject *parent = nullptr);
    ~ServerHandler();

    bool startServer(quint16 port = 8080);
    void stopServer();

    int serverPort() const { return m_port; }
    int clientCount() const { return m_clientMap.size(); }

signals:
    void newMessage(const QString &message);
    void clientConnected(const QString &clientInfo);
    void clientDisconnected(const QString &clientInfo);
    void serverStarted();
    void serverStopped();

private slots:
    void handleNewConnection();
    void handleClientDisconnected();
    void handleClientData();

private:
    QTcpServer *m_server;
    quint16 m_port;
    QMap<QString, ClientInfo> m_clientMap;

    void broadcastClientList();
    void sendToClient(const QString &clientId, const QByteArray &data);
};
