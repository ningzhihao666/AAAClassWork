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
    , m_followingCount("0")
    , m_fansCount("0")
    , m_likes("0")
    , m_isPremiunMembership(false)
    , m_account(account)
    ,m_password(password)
    , m_headportraitTempFile("")
{}

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
