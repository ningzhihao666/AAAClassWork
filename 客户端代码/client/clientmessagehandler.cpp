#include "clientmessagehandler.h"
#include <QHostInfo>
#include <QNetworkInterface>

ClientMessageHandler::ClientMessageHandler(QObject *parent) : QObject(parent)
{
    connect(&m_clientHandler, &ClientHandler::newMessage, this, &ClientMessageHandler::addMessage);
    connect(&m_clientHandler, &ClientHandler::connected, this, [this]() { addMessage("Connected to server"); });
    connect(&m_clientHandler, &ClientHandler::disconnected, this, [this]() { addMessage("Disconnected from server"); });

    updateHostInfo();
}

void ClientMessageHandler::addMessage(const QString &msg)
{
    m_message = msg;
    emit messageChanged();
}

void ClientMessageHandler::updateHostInfo()
{
    m_hostname = QHostInfo::localHostName();
    emit serverInfoChanged();
}
