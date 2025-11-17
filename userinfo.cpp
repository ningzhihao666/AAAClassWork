#include <QFile>
#include <QStandardPaths>
#include <QUrl>
#include <QIODevice>


#include "userinfo.h"
#include "user.h"



UserInfo::UserInfo(QString nickname,QString account,QString password, User *parent)
    : QObject(parent)
    , _owner(parent)
    , m_nickname(nickname)
    , m_sign("")
    , m_headportrait("")
    , m_level("1")
    , m_followingCount("")
    , m_fansCount("")
    , m_likes("0")
    , m_isPremiunMembership(false)
    , m_account(account)
    ,m_password(password)
    , m_headportraitTempFile("")
{}

UserInfo::UserInfo(const QSqlRecord &record, User *parent)
    : QObject(parent)
    , _owner(parent)
{
    // 直接从数据库记录初始化所有属性
    m_account = record.value("account").toString();
    m_nickname = record.value("nickname").toString();
    m_password = record.value("password").toString();
    m_sign = record.value("sign").toString();
    m_headportrait = record.value("headportrait").toString();
    m_level = record.value("level").toString();
    m_followingCount = record.value("followingCount").toString();
    m_fansCount = record.value("fansCount").toString();
    m_likes = record.value("likes").toString();
    m_isPremiunMembership = record.value("isPremiunMembership").toBool();
    m_headportraitTempFile = "";

    // 添加调试信息
    // if (m_account == "account123") {
    //     qDebug() << "🔍 DEBUG - UserInfo 数据库构造函数:";
    //     qDebug() << "  m_followingCount 设置为:" << m_followingCount;
    //     qDebug() << "  m_level 设置为:" << m_level;
    //     qDebug() << "  m_fansCount 设置为:" << m_fansCount;
    // }
}

UserInfo::~UserInfo() {}

void UserInfo::setPassword(const QString &password)
{
    if (password != m_password) {
        m_password = password;
        emit passwordChanged();

    }
}

void UserInfo::setNickname(const QString &nickname)
{
    if (nickname != m_nickname) {
        m_nickname = nickname;
        emit nicknameChanged();
    }
}

void UserInfo::setSign(const QString &sign)
{
    if (sign != m_sign) {
        m_sign = sign;
        emit signChanged();
    }
}

void UserInfo::setHeadportrait(const QString &base64)
{
    if (m_headportrait != base64) {
        m_headportrait = base64;
        emit headportraitChanged();
    }
}

void UserInfo::setHeadportraitFromFile(const QString &filePath)
{
    QString localPath = QUrl(filePath).toLocalFile();

    QFile file(localPath);
    if (!file.open(QIODevice::ReadOnly)) { return; }

    QByteArray imageData = file.readAll();
    file.close();

    if (imageData.isEmpty()) { return; }

    //检查JPEG和PNG格式
    bool isValid = imageData.startsWith("\xFF\xD8\xFF") || // JPEG
                   imageData.startsWith("\x89PNG");        // PNG

    if (!isValid) { return; }

    //base64
    QString base64 = QString::fromLatin1(imageData.toBase64());

    QString imageType = imageData.startsWith("\xFF\xD8\xFF") ? "jpeg" : "png";
    QString formattedBase64 = QString("data:image/%1;base64,%2").arg(imageType, base64);

    setHeadportrait(formattedBase64);
}

void UserInfo::setAccount(const QString &account) {
    if (account != m_account) {
        m_account = account;
    }
}

void UserInfo::setLevel(const QString &level)
{
    if (level != m_level) {
        m_level = level;
        emit levelChanged();
    }
}

void UserInfo::setFollowingCount(const QString &followingCount)
{
    if (followingCount != m_followingCount) {
        m_followingCount = followingCount;
        emit followingCountChanged();
    }
}

void UserInfo::setFansCount(const QString &fansCount)
{
    if (fansCount != m_fansCount) {
        m_fansCount = fansCount;
        emit fansCountChanged();
    }
}

void UserInfo::setLikes(const QString &likes)
{
    if (likes != m_likes) {
        m_likes = likes;
        emit likesChanged();
    }
}

void UserInfo::setIsPremiunMembership(const bool isPremiunMembership)
{
    if (isPremiunMembership != m_isPremiunMembership) {
        m_isPremiunMembership = isPremiunMembership;
        emit isPremiunMembershipChanged();
    }
}


// 收藏视频和历史记录相关方法实现
void UserInfo::setFavoriteVideos(const QStringList &favoriteVideos)
{
    if (favoriteVideos != m_favoriteVideos1) {
        m_favoriteVideos1 = favoriteVideos;
        emit favoriteVideosChanged();
    }
}

void UserInfo::setWatchHistory(const QStringList &watchHistory)
{
    if (watchHistory != m_watchHistory) {
        m_watchHistory = watchHistory;
        emit watchHistoryChanged();
    }
}

void UserInfo::addFavoriteVideo(const QString &videoId)
{
    if (!m_favoriteVideos1.contains(videoId)) {
        m_favoriteVideos1.append(videoId);
        emit favoriteVideosChanged();
    }
}

void UserInfo::removeFavoriteVideo(const QString &videoId)
{
    if (m_favoriteVideos1.removeOne(videoId)) {
        emit favoriteVideosChanged();
    }
}

void UserInfo::addWatchHistory(const QString &videoId)
{
    // 如果已经存在，先移除再添加到开头，保持最近观看的在前面
    m_watchHistory.removeOne(videoId);
    m_watchHistory.prepend(videoId);

    // 限制历史记录数量，避免无限增长（例如最多100条）
    if (m_watchHistory.size() > 100) {
        m_watchHistory = m_watchHistory.mid(0, 100);
    }

    emit watchHistoryChanged();
}

void UserInfo::clearWatchHistory()
{
    if (!m_watchHistory.isEmpty()) {
        m_watchHistory.clear();
        emit watchHistoryChanged();
    }
}


// 关注关系相关方法实现
bool UserInfo::follow(UserInfo *user)
{
    if (!user || user == this || m_following.contains(user)) {
        return false;
    }

    m_following.insert(user);
    user->addFollower(this);

    // 更新关注数
    setFollowingCount(QString::number(m_following.size()));

    emit followingChanged();
    return true;
}

bool UserInfo::unfollow(UserInfo *user)
{
    if (!user || !m_following.contains(user)) {
        return false;
    }

    m_following.remove(user);
    user->removeFollower(this);

    // 更新关注数
    setFollowingCount(QString::number(m_following.size()));

    emit followingChanged();
    return true;
}

void UserInfo::addFollower(UserInfo *user)
{
    if (user && user != this) {
        m_followers.insert(user);
        // 更新粉丝数
        setFansCount(QString::number(m_followers.size()));
        emit followersChanged();
    }
}

void UserInfo::removeFollower(UserInfo *user)
{
    if (user) {
        m_followers.remove(user);
        // 更新粉丝数
        setFansCount(QString::number(m_followers.size()));
        emit followersChanged();
    }
}

// 收藏
bool UserInfo::collectVideo(Vedio* video) {
    // if (!video || m_collectedVideos.contains(video)) {
    //     return false;
    // }

    // m_collectedVideos.insert(video);

    // // 使用 video->changeCollect() 来增加收藏数量
    // int currentCollect = video->collectionCount();
    // video->changeCollect(currentCollect);




    // qDebug() << "用户" << m_nickname << "收藏视频:" << video->title();
    // emit collectedVideosChanged();
    // return true;

    if (!video || m_collectedVideos.contains(video)) {
        return false;
    }

    m_collectedVideos.insert(video);


    if (EventController::instance() && EventController::instance()->videoManager()) {
        EventController::instance()->videoManager()->increaseCollect(video->videoId(), video->collectionCount());
    }else {
        qWarning() << "❌ EventController 的 VideoManager 为空";
        // 备用方案：直接使用 video->changeCollect()
        //int currentCollect = video->collectionCount();
        //video->changeCollect(currentCollect);
    }

    qDebug() << "用户" << m_nickname << "收藏视频:" << video->title();
    emit collectedVideosChanged();
    return true;
}

bool UserInfo::uncollectVideo(Vedio* video) {
    if (!video || !m_collectedVideos.contains(video)) {
        return false;
    }

    m_collectedVideos.remove(video);

    // 减少视频的收藏数量
    //video->decreaseCollection();
    // 因为 Vedio 类没有提供 decreaseCollect 方法
    int currentCollect = video->collectionCount();
    if (currentCollect > 0) {
        video->setCollectionCount(currentCollect - 1);
    }

    qDebug() << "用户" << m_nickname << "取消收藏视频:" << video->title();
    emit collectedVideosChanged();
    return true;
}

QStringList UserInfo::getFavoriteVideoIds() const {
    QStringList ids;
    for (Vedio* video : m_collectedVideos) {
        ids.append(video->videoId());
    }
    return ids;
}

