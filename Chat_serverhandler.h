#pragma once
#include <QTcpServer>
#include <QTcpSocket>
#include <QObject>
#include <QList>
#include <QNetworkInterface>
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
    Q_PROPERTY(QString ip READ getIp NOTIFY ipChanged)
public:
    explicit ServerHandler(QObject *parent = nullptr);

    bool startServer(quint16 port = 8080);
    void stopServer();
    void sendToAll(const QString &message);

    int serverPort() const { return m_port; }
    int clientCount() const { return m_clients.size(); }
    QStringList clientIps() const;
    QString getIp() const { return m_ip; }

signals:
    void newMessage(const QString &message);
    void clientConnected(const QString &clientInfo);
    void clientDisconnected(const QString &clientInfo);
    void serverStarted();
    void serverStopped();
    void ipChanged();

private slots:
    void handleNewConnection();
    void handleClientDisconnected();
    void handleClientData();

private:
    QTcpServer *m_server;
    QList<QTcpSocket *> m_clients;
    quint16 m_port;

    QString m_ip = "未连接";

    void updateServerInfo();

    QMap<QString, ClientInfo> m_clientMap; // 新增客户端映射
    void broadcastClientList();            // 新增广播列表方法
};
