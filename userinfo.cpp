#include <QFile>
#include <QStandardPaths>
#include <QUrl>

#include "userinfo.h"
#include "user.h"

UserInfo::UserInfo(QString nickname, User *parent)
    : QObject(parent)
    , _owner(parent)
    , m_nickname(nickname)
{}

UserInfo::~UserInfo() {}

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

void UserInfo::setFansCount(const QString &followingCount)
{
    if (followingCount != m_followingCount) {
        m_followingCount = followingCount;
        emit followingCountChanged();
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
