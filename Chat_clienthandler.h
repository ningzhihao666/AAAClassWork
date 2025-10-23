#pragma once
#include <QTcpSocket>
#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

class ClientHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList clientList READ clientList NOTIFY clientListChanged) // 添加属性

    Q_PROPERTY(QString chatHistory READ chatHistory NOTIFY chatHistoryChanged) //额外
    Q_PROPERTY(QString serverIp READ serverIp NOTIFY serverInfoChanged)        // 添加获得服务端IP属性
    Q_PROPERTY(quint16 serverPort READ serverPort NOTIFY serverInfoChanged)    // 添加获得服务端端口属性
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
public:
    explicit ClientHandler(QObject *parent = nullptr);

    bool connectToServer(const QString &host, quint16 port = 8080);
    void disconnectFromServer();
    void sendMessage(const QString &message);

    bool isConnected() const { return m_socket && m_socket->state() == QAbstractSocket::ConnectedState; }
    int serverPort() const { return m_port; }
    QString clientId() const { return m_clientId; } // 添加访问器
    QStringList clientList() const { return m_clientList; }

    QString chatHistory() const { return m_chatHistory; }                       // 统一聊天历史
    Q_INVOKABLE void sendToClient(const QString &name, const QString &message); // 新增方法
    Q_INVOKABLE void handleSocketConnected();                                   //新增
    Q_INVOKABLE void setActiveChat(const QString &clientId);                    // 新增：设置当前活动聊天

    QString serverIp() const { return m_server_ip; } // 添加访问器

    QString name() const { return m_name; }
    Q_INVOKABLE void setName(const QString &name); // 设置名字

    // 添加方法：通过名字获取客户端ID
    Q_INVOKABLE QString getClientIdByName(const QString &name);

signals:
    void newMessage(const QString &message);
    void connected();
    void disconnected();

    void clientListChanged();                                          // 新增信号
    void messageReceived(const QString &from, const QString &message); // 新增信号
        // 添加连接成功处理

    void chatHistoryChanged(); // 聊天历史变化信号

    void serverInfoChanged();
    void nameChanged(const QString &name);

private slots:
    void handleDataReceived();
    void handleSocketError(QAbstractSocket::SocketError error);

private:
    QTcpSocket *m_socket;
    quint16 m_port;           // 连接的服务端端口
    QString m_clientId;       // 添加客户端ID成员
    QStringList m_clientList; // 添加客户端列表存储

    QString m_server_ip; // 连接的服务端ip

    QString m_chatHistory;                       // 统一聊天历史
    QString m_activeChat;                        // 当前活动聊天对象
    void addChatMessage(const QString &message); // 添加消息辅助函数
    QString m_name;                              //客户端名字

    // 添加映射：名字 -> ID
    QMap<QString, QString> m_nameToIdMap;
};
