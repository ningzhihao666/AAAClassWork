#pragma once
#include <QObject>
#include <QString>
#include <QDateTime>
#include <QVector>

class Comment : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)
    Q_PROPERTY(QDateTime time READ time WRITE setTime NOTIFY timeChanged)
    Q_PROPERTY(QString content READ content WRITE setContent NOTIFY contentChanged)
    Q_PROPERTY(int likeCount READ likeCount WRITE setLikeCount NOTIFY likeCountChanged)
    Q_PROPERTY(int unlikeCount READ unlikeCount WRITE setUnlikeCount NOTIFY unlikeCountChanged)
    Q_PROPERTY(bool isReply READ isReply WRITE setIsReply NOTIFY isReplyChanged)
    Q_PROPERTY(QString parentId READ parentId WRITE setParentId NOTIFY parentIdChanged)
    Q_PROPERTY(QString replyModelId READ replyModelId WRITE setReplyModelId NOTIFY replyModelIdChanged)
    Q_PROPERTY(QVector<Comment*> replies READ replies NOTIFY repliesChanged)

public:
    explicit Comment(QObject *parent = nullptr);
    explicit Comment(const QString &userName, const QString &content, QObject *parent = nullptr);

    QString id() const { return m_id; }

    QString userName() const { return m_userName; }
    void setUserName(const QString &userName) {
        if (m_userName != userName) {
            m_userName = userName;
            emit userNameChanged();
        }
    }

    QDateTime time() const { return m_time; }
    void setTime(const QDateTime &time) {
        if (m_time != time) {
            m_time = time;
            emit timeChanged();
        }
    }

    QString content() const { return m_content; }
    void setContent(const QString &content) {
        if (m_content != content) {
            m_content = content;
            emit contentChanged();
        }
    }

    int likeCount() const { return m_likeCount; }
    void setLikeCount(int count) {
        if (m_likeCount != count) {
            m_likeCount = count;
            emit likeCountChanged();
        }
    }

    int unlikeCount() const { return m_unlikeCount; }
    void setUnlikeCount(int count) {
        if (m_unlikeCount != count) {
            m_unlikeCount = count;
            emit unlikeCountChanged();
        }
    }

    bool isReply() const { return m_isReply; }
    void setIsReply(bool isReply) {
        if (m_isReply != isReply) {
            m_isReply = isReply;
            emit isReplyChanged();
        }
    }

    QString parentId() const { return m_parentId; }
    void setParentId(const QString &parentId) {
        if (m_parentId != parentId) {
            m_parentId = parentId;
            emit parentIdChanged();
        }
    }

    QString replyModelId() const { return m_replyModelId; }
    void setReplyModelId(const QString &replyModelId) {
        if (m_replyModelId != replyModelId) {
            m_replyModelId = replyModelId;
            emit replyModelIdChanged();
        }
    }

    QVector<Comment*> replies() const { return m_replies; }

    // 添加回复
    void addReply(Comment *reply) {
        if (reply) {
            reply->setIsReply(true);
            reply->setParentId(m_id);
            m_replies.append(reply);
            emit repliesChanged();
        }
    }

    // 格式化时间显示
    QString formattedTime() const {
        qint64 secs = m_time.secsTo(QDateTime::currentDateTime());
        if (secs < 60) return "刚刚";
        if (secs < 3600) return QString("%1分钟前").arg(secs / 60);
        if (secs < 86400) return QString("%1小时前").arg(secs / 3600);
        return QString("%1天前").arg(secs / 86400);
    }

signals:
    void userNameChanged();
    void timeChanged();
    void contentChanged();
    void likeCountChanged();
    void unlikeCountChanged();
    void isReplyChanged();
    void parentIdChanged();
    void replyModelIdChanged();
    void repliesChanged();

private:
    QString m_id;                  //评论唯一标识符
    QString m_userName;            //发表评论用户名
    QDateTime m_time;              //评论时间
    QString m_content;             //评论内容
    int m_likeCount = 0;           //点赞数量
    int m_unlikeCount = 0;         //点踩数量
    bool m_isReply = false;        //是否为回复
    QString m_parentId;            //父评论
    QString m_replyModelId;        //回复id
    QVector<Comment*> m_replies;   //回复列表
};
