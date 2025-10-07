#pragma once

#include <QObject>
#include <QString>

class User;

class UserInfo : public QObject
{
    Q_OBJECT
public:
    UserInfo(QString nickname, User *parent = nullptr);
    ~UserInfo();

    QString getNickname() { return m_nickname; }
    QString getSign() { return m_sign; }
    QString getHeadportrait() { return m_headportrait; }
    QString getLevel() { return m_level; }
    QString getFollowingCount() { return m_followingCount; }
    QString getFansCount() { return m_fansCount; }
    QString getLikes() { return m_likes; }
    QString getAccount() { return m_account; }
    bool getIsPremiunMembership() { return m_isPremiunMembership; }
    void setNickname(const QString &nickname);
    void setSign(const QString &sign);
    void setHeadportrait(const QString &base64);
    void setLevel(const QString &level);
    void setFollowingCount(const QString &followingCount);
    void setFansCount(const QString &fansCount);
    void setLikes(const QString &likes);
    void setIsPremiunMembership(const bool isPremiunMembership);

signals:
    void nicknameChanged();
    void signChanged();
    void headportraitChanged();
    void levelChanged();
    void followingCountChanged();
    void fansCountChanged();
    void likesChanged();
    void isPremiunMembershipChanged();

private:
    QString m_nickname;
    QString m_sign;
    QString m_headportrait;
    QString m_level;            //等级
    QString m_followingCount;   //关注数
    QString m_fansCount;        //粉丝数
    QString m_likes;            //获赞数
    bool m_isPremiunMembership; //是否为大会员
    QString m_account;

    User *_owner;
};
