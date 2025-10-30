#pragma once
#include <QObject>
#include "clienthandler.h"

class ClientMessageHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString message READ message NOTIFY messageChanged)
    Q_PROPERTY(QString hostname READ hostname NOTIFY serverInfoChanged)
    Q_PROPERTY(ClientHandler *clientHandler READ clientHandler CONSTANT)

public:
    explicit ClientMessageHandler(QObject *parent = nullptr);

    QString message() const { return m_message; }
    QString hostname() const { return m_hostname; }
    ClientHandler *clientHandler() { return &m_clientHandler; }

public slots:
    void addMessage(const QString &msg);

signals:
    void messageChanged();
    void serverInfoChanged();

private:
    ClientHandler m_clientHandler;
    QString m_message;
    QString m_hostname;

    void updateHostInfo();
};
