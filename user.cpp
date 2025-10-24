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

    //_uinfo->setAccount(account);

    //_uinfo->setPassword(password);

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

