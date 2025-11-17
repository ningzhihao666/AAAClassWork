#include "comment.h"
#include <QUuid>

Comment::Comment(QObject *parent) : QObject(parent) {
    m_id = QUuid::createUuid().toString();
    m_time = QDateTime::currentDateTime();
    m_replyModelId = QString("replies_%1").arg(m_id);
}

Comment::Comment(const QString &userName, const QString &content, QObject *parent)
    : QObject(parent), m_userName(userName), m_content(content) {
    m_id = QUuid::createUuid().toString();
    m_time = QDateTime::currentDateTime();
    m_replyModelId = QString("replies_%1").arg(m_id);
}

