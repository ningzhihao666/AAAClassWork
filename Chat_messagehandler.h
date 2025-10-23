// messagehandler.h
#pragma once
#include <QObject>
#include "Chat_serverhandler.h"
#include "Chat_clienthandler.h"
#include <QTimer>

class MessageHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString message READ message NOTIFY messageChanged)
    Q_PROPERTY(int serverPort READ serverPort NOTIFY serverInfoChanged)
    Q_PROPERTY(QString hostname READ hostname NOTIFY serverInfoChanged)
    Q_PROPERTY(QStringList ipAddresses READ ipAddresses NOTIFY serverInfoChanged)
    Q_PROPERTY(QStringList clientIps READ clientIps NOTIFY clientCountChanged)
    Q_PROPERTY(int clientCount READ clientCount NOTIFY clientCountChanged)
    Q_PROPERTY(ClientHandler *clientHandler READ clientHandler CONSTANT)
    Q_PROPERTY(ServerHandler *serverHandler READ serverHandler CONSTANT)

public:
    explicit MessageHandler(QObject *parent = nullptr);

    QString message() const { return m_message; }
    int serverPort() const { return m_serverHandler.serverPort(); }
    QString hostname() const { return m_hostname; }
    QStringList ipAddresses() const { return m_ipAddresses; }
    QStringList clientIps() const { return m_serverHandler.clientIps(); }
    int clientCount() const { return m_serverHandler.clientCount(); }
    ClientHandler *clientHandler() { return &m_clientHandler; }
    ServerHandler *serverHandler() { return &m_serverHandler; }

public slots:
    void addMessage(const QString &msg);
    void startServer();
    void stopServer();
    void startClient();
    void sendToServer(const QString &message);
    void sendToClients(const QString &message);

signals:
    void messageChanged();
    void serverInfoChanged();
    void clientCountChanged();

private:
    ServerHandler m_serverHandler;
    ClientHandler m_clientHandler;
    QString m_message;
    QString m_hostname;
    QStringList m_ipAddresses;
    bool server = false;

    void updateHostInfo();
};
