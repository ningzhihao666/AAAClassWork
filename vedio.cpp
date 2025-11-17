#include "vedio.h"
#include <QDateTime>
#include <QDebug>
#include <random>

Vedio::Vedio(QObject *parent)
    : QObject(parent)
    , m_videoUrl("")
    , m_coverUrl("")
{
    // 生成唯一ID
    m_id = generateUniqueId();
    m_uploadDate = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
    qDebug() << "创建视频对象，ID:" << m_id;
}


Vedio::Vedio(const QString &title, const QString &author, QObject *parent)
    : QObject(parent)
    , m_title(title)
    , m_author(author)
    , m_videoUrl("")
    , m_coverUrl("")
{
    // 生成唯一ID
    m_id = generateUniqueId();
    m_uploadDate = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
    qDebug() << "创建视频对象，ID:" << m_id << "标题:" << title << "作者:" << author;
}


int Vedio::changeViews(int currentViews) {
    qDebug() << "Vedio::changeViews - 当前播放量:" << m_viewCount << "传入值:" << currentViews;

    // 增加播放量
    int newViews = m_viewCount + 1;
    setViewCount(newViews);

    qDebug() << "✅ 播放量更新:" << m_viewCount << "->" << newViews;

    return newViews;
}

int Vedio::changeLikes(int currentLikes)
{
    int newLikes = m_likeCount + 1;

    qDebug() << "✅ 点赞更新:" << m_likeCount << "->" << newLikes;

    setLikeCount(newLikes);

    return newLikes;
}

int Vedio::changCoin(int currentCoin)
{
    int newCoin = m_coinCount + 1;
    qDebug() << "✅ 硬币更新:" << m_coinCount << "->" << newCoin;
    setCoinCount(newCoin);
    return newCoin;
}

int Vedio::changeCollect(int currentCollect)
{
    int newCollect = m_collectionCount + 1;
    setCollectionCount(newCollect);
    return newCollect;
}

bool Vedio::downLoad()
{
    m_downloaded = !m_downloaded;
    return m_downloaded;
}

int Vedio::changeforward(int currentForward)
{
    int newforward = m_forwardCount + 1;
    qDebug() << "✅ 转发更新:" << m_forwardCount << "->" << newforward;
    setForwardCount(newforward);
    return newforward;
}

QString Vedio::generateUniqueId() {
    qint64 timestamp = QDateTime::currentMSecsSinceEpoch();

    // 使用 C++11 随机数生成器
    static std::random_device rd;
    static std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(0, 9999);
    int random = dis(gen);

    return QString("video_%1_%2").arg(timestamp).arg(random, 4, 10, QChar('0'));
}

void Vedio::addComment(const QString &userName, const QString &content) {
    Comment* newComment = new Comment(userName, content, this);
    m_comments.append(newComment);
    m_commentMap[newComment->id()] = newComment;

    // 更新评论计数
    setCommitCount(m_commitCount + 1);

    qDebug() << "添加评论:" << userName << "内容:" << content << "id为："<<newComment->id();

    emit commentsChanged();
    emit commentAdded(newComment);
    emit commitChanged();
}

void Vedio::addReply(const QString &parentCommentId, const QString &userName, const QString &content) {
    if (m_commentMap.contains(parentCommentId)) {
        Comment* parentComment = m_commentMap.value(parentCommentId);
        Comment* reply = new Comment(userName, content, this);
        reply->setIsReply(true);
        reply->setParentId(parentCommentId);

        parentComment->addReply(reply);

        // 更新评论计数
        setCommitCount(m_commitCount + 1);

        qDebug() << "添加回复到评论" << parentCommentId << "用户:" << userName;

        emit commentsChanged();
        emit replyAdded(parentCommentId, reply);
        emit commitChanged();
    } else {
        qWarning() << "未找到父评论:" << parentCommentId;
    }
}

Comment* Vedio::getCommentById(const QString &commentId) {
    return m_commentMap.value(commentId, nullptr);
}
