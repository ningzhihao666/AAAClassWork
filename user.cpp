#include <qvariant.h>
#include <QCryptographicHash>

#include "user.h"
#include "userinfo.h"

User::User(QObject *parent)
    : QObject(parent)
{
    //_uinfo = new UserInfo("", this);
}
User::User(const QString &nickname, const QString &account, const QString &password, QObject *parent)
{
    // 初始化用户资料
    _uinfo = new UserInfo(nickname,account,password, this);  //其他属性用userinfo的初始化


    signalConnect();
}

User::User(const QSqlRecord &record, QObject *parent)
    : QObject(parent)
{
    // 使用新的 UserInfo 构造函数，直接传入数据库记录
    _uinfo = new UserInfo(record, this);
    signalConnect();
}

User::~User()
{
    delete _uinfo;
}

void User::signalConnect()
{
    connect(_uinfo, &UserInfo::passwordChanged, this, &User::passwordChanged);
    connect(_uinfo, &UserInfo::nicknameChanged, this, &User::nicknameChanged);  //User::nicknameChanged发送后，QML引擎响应信号，并重新读取user.nickname 属性值
    connect(_uinfo, &UserInfo::signChanged, this, &User::signChanged);
    connect(_uinfo, &UserInfo::headportraitChanged, this, &User::headportraitChanged);
    connect(_uinfo, &UserInfo::levelChanged, this, &User::levelChanged);
    connect(_uinfo, &UserInfo::followingCountChanged, this, &User::followingCountChanged);
    connect(_uinfo, &UserInfo::fansCountChanged, this, &User::fansCountChanged);
    connect(_uinfo, &UserInfo::likesChanged, this, &User::likesChanged);
    connect(_uinfo, &UserInfo::isPremiunMembershipChanged, this, &User::isPremiunMembershipChanged);

    // 新增信号的连接
    connect(_uinfo, &UserInfo::favoriteVideosChanged, this, &User::favoriteVideosChanged);
    connect(_uinfo, &UserInfo::watchHistoryChanged, this, &User::watchHistoryChanged);

    // 连接关注关系信号
    connect(_uinfo, &UserInfo::followingChanged, this, &User::followingChanged);
    connect(_uinfo, &UserInfo::followersChanged, this, &User::followersChanged);
}

// 属性获取
QString User::getNickname()
{
    return _uinfo->getNickname();
}

QString User::getAccount()
{
    return _uinfo->getAccount();
}

QString User::getPassword()
{
    return _uinfo->getPassword();
}

bool User::isPremiunMembership()
{
    return _uinfo->getIsPremiunMembership();
}

QString User::getSign()
{
    return _uinfo->getSign();
}

QString User::getHeadportrait()
{
    return _uinfo ? _uinfo->getHeadportrait() : "";
}

QString User::getLevel()
{
    return _uinfo->getLevel();
}

QString User::getFollowingCount()
{
    return _uinfo->getFollowingCount();
}

QString User::getFansCount()
{
    return _uinfo->getFansCount();
}

QString User::getLikes()
{
    return _uinfo->getLikes();
}

// 属性更新
void User::setPassword(const QString &password) {
    _uinfo->setPassword(password);
}

void User::setAccount(const QString &account)
{
    _uinfo->setAccount(account);
}
void User::setNickname(const QString &nickname)
{
    _uinfo->setNickname(nickname);
}

void User::setSign(const QString &sign)
{
    _uinfo->setSign(sign);
}

void User::setHeadportrait(const QString &base64)
{
    _uinfo->setHeadportrait(base64);
}

void User::setLevel(const QString &level)
{
    _uinfo->setLevel(level);
}

void User::setFollowingCount(const QString &followingCount)
{
    _uinfo->setFollowingCount(followingCount);
}

void User::setFansCount(const QString &fansCount)
{
    _uinfo->setFansCount(fansCount);
}

void User::setLikes(const QString &likes)
{
    _uinfo->setLikes(likes);
}

void User::setIsPremiunMembership(const bool isPremiunMembership)
{
    _uinfo->setIsPremiunMembership(isPremiunMembership);
}


// 收藏视频和历史记录相关方法实现
QStringList User::getFavoriteVideos()
{
    return _uinfo ? _uinfo->getFavoriteVideos() : QStringList();
}

QStringList User::getWatchHistory()
{
    return _uinfo ? _uinfo->getWatchHistory() : QStringList();
}

void User::setFavoriteVideos(const QStringList &favoriteVideos)
{
    if (_uinfo) {
        _uinfo->setFavoriteVideos(favoriteVideos);
    }
}

void User::setWatchHistory(const QStringList &watchHistory)
{
    if (_uinfo) {
        _uinfo->setWatchHistory(watchHistory);
    }
}

void User::addFavoriteVideo(const QString &videoId)
{
    if (_uinfo) {
        _uinfo->addFavoriteVideo(videoId);
    }
}

void User::removeFavoriteVideo(const QString &videoId)
{
    if (_uinfo) {
        _uinfo->removeFavoriteVideo(videoId);
    }
}

void User::addWatchHistory(const QString &videoId)
{
    if (_uinfo) {
        _uinfo->addWatchHistory(videoId);
    }
}

void User::clearWatchHistory()
{
    if (_uinfo) {
        _uinfo->clearWatchHistory();
    }
}


// 关注关系相关方法实现
bool User::follow(User *user)
{
    if (_uinfo && user && user->_uinfo) {
        if (isFollowing(user)) {
            qDebug() << "⚠️ 已经关注了该用户:" << user->getAccount();
            return false;
        }
        return _uinfo->follow(user->_uinfo);
    }
    return false;
}

bool User::unfollow(User *user)
{
    if (_uinfo && user && user->_uinfo) {
        return _uinfo->unfollow(user->_uinfo);
    }
    return false;
}

bool User::isFollowing(User *user)
{
    if (_uinfo && user && user->_uinfo) {
        return _uinfo->isFollowing(user->_uinfo);
    }
    return false;
}

bool User::isFollowedBy(User *user)
{
    if (_uinfo && user && user->_uinfo) {
        return _uinfo->isFollowedBy(user->_uinfo);
    }
    return false;
}

QStringList User::getFollowingAccounts()
{
    QStringList accounts;
    if (_uinfo) {
        for (UserInfo *following : _uinfo->getFollowing()) {
            accounts.append(following->getAccount());
        }
    }
    return accounts;
}

QStringList User::getFollowerAccounts()
{
    QStringList accounts;
    if (_uinfo) {
        for (UserInfo *follower : _uinfo->getFollowers()) {
            accounts.append(follower->getAccount());
        }
    }
    return accounts;
}


// 收藏
bool User::collectVideo(Vedio* video) {
    if (_uinfo && video) {
        return _uinfo->collectVideo(video);
    }
    return false;
}

bool User::uncollectVideo(Vedio* video) {
    if (_uinfo && video) {
        return _uinfo->uncollectVideo(video);
    }
    return false;
}

bool User::hasCollectedVideo(Vedio* video) {
    if (_uinfo && video) {
        return _uinfo->hasCollectedVideo(video);
    }
    return false;
}

QSet<Vedio*> User::getCollectedVideos() {
    return _uinfo ? _uinfo->getCollectedVideos() : QSet<Vedio*>();
}

QStringList User::getFavoriteVideoIds() {
    return _uinfo ? _uinfo->getFavoriteVideoIds() : QStringList();
}
