#pragma once
#include <QTcpSocket>
#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QMap>
#include <QTimer>

class ClientHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList clientList READ clientList NOTIFY clientListChanged)
    Q_PROPERTY(QString chatHistory READ chatHistory NOTIFY chatHistoryChanged)
    Q_PROPERTY(QString serverIp READ serverIp NOTIFY serverInfoChanged)
    Q_PROPERTY(quint16 serverPort READ serverPort NOTIFY serverInfoChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionChanged)
    Q_PROPERTY(bool connecting READ isConnecting NOTIFY connectingChanged)

public:
    explicit ClientHandler(QObject *parent = nullptr);
    ~ClientHandler();

    Q_INVOKABLE bool connectToServer(const QString &host, quint16 port = 8080);
    Q_INVOKABLE void disconnectFromServer();
    Q_INVOKABLE void sendToClient(const QString &name, const QString &message);
    Q_INVOKABLE void setActiveChat(const QString &clientName);
    Q_INVOKABLE QString getClientIdByName(const QString &name);
    Q_INVOKABLE void reconnect();
    Q_INVOKABLE void setName(const QString &name);
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Q_INVOKABLE void requestChatHistory(const QString &contactName);
    Q_INVOKABLE void loadChatHistory(const QString &contactName);

    QStringList clientList() const { return m_clientList; }
    QString chatHistory() const { return m_chatHistory; }
    QString serverIp() const { return m_serverIp; }
    quint16 serverPort() const { return m_serverPort; }
    QString name() const { return m_name; }
    bool isConnected() const { return m_socket && m_socket->state() == QAbstractSocket::ConnectedState; }
    bool isConnecting() const { return m_connecting; }

signals:
    void newMessage(const QString &message);
    void connected();
    void disconnected();
    void clientListChanged();
    void chatHistoryChanged();
    void serverInfoChanged();
    void nameChanged(const QString &name);
    void connectionChanged();
    void connectingChanged(bool connecting);
    void connectionError(const QString &errorMessage);
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    void historyReceived(const QString &contactName, const QString &history);

private slots:
    void handleDataReceived();
    void handleSocketConnected();
    void handleSocketDisconnected();
    void handleSocketError(QAbstractSocket::SocketError error);
    void handleConnectionTimeout();

private:
    QTcpSocket *m_socket;
    QString m_name = "Anonymous";
    QString m_serverIp;
    quint16 m_serverPort = 0;
    QStringList m_clientList;
    QString m_chatHistory;
    QMap<QString, QString> m_nameToIdMap;

    // 新增错误处理相关成员
    bool m_connecting = false;
    QString m_lastHost;
    quint16 m_lastPort = 0;
    QTimer *m_connectionTimer;
    int m_retryCount = 0;
    const int MAX_RETRIES = 3;
    const int CONNECTION_TIMEOUT = 10000; // 10秒超时

    void addChatMessage(const QString &message);
    void processJson(const QJsonObject &obj);
    void setConnecting(bool connecting); // 设置连接状态
    void attemptReconnection();          // 尝试重连
};
