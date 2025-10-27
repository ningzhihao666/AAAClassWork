//数据存储类
#pragma once

#include <QObject>
#include <QString>

//头像所需库
#include <QImage>
#include <QByteArray>
#include <QFile>
#include <QStandardPaths>
#include <QUrl>
#include <QDir>
#include <QDateTime>

class User;

class UserInfo : public QObject
{
    Q_OBJECT
public:
    UserInfo(QString nickname,QString account,QString password, User *parent = nullptr);
    ~UserInfo();

    //暴露给user,让user可以获取属性
    QString getPassword() {return m_password;}
    QString getNickname() { return m_nickname; }
    QString getSign() { return m_sign; }
    QString getHeadportrait() { return m_headportrait; }
    QString getLevel() { return m_level; }
    QString getFollowingCount() { return m_followingCount; }
    QString getFansCount() { return m_fansCount; }
    QString getLikes() { return m_likes; }
    QString getAccount() { return m_account; }
    QString getHeadportraitTempFile() { return m_headportraitTempFile; }

    // 设置属性
    void setAccount(const QString &account);
    void setPassword(const QString &password);
    bool getIsPremiunMembership() { return m_isPremiunMembership; }
    void setNickname(const QString &nickname);
    void setSign(const QString &sign);
    void setHeadportrait(const QString &base64);
    void setHeadportraitFromFile(const QString &filePath);
    void setLevel(const QString &level);
    void setFollowingCount(const QString &followingCount);
    void setFansCount(const QString &fansCount);
    void setLikes(const QString &likes);
    void setIsPremiunMembership(const bool isPremiunMembership);

signals:
    void passwordChanged();
    void accoutChanged();
    void nicknameChanged();
    void signChanged();
    void headportraitChanged();
    void levelChanged();
    void followingCountChanged();
    void fansCountChanged();
    void likesChanged();
    void isPremiunMembershipChanged();

private:
    QString m_password;
    QString m_nickname;
    QString m_sign;
    QString m_headportrait;
    QString m_level;            //等级
    QString m_followingCount;   //关注数
    QString m_fansCount;        //粉丝数
    QString m_likes;            //获赞数
    bool m_isPremiunMembership; //是否为大会员
    QString m_account;
    QString m_headportraitTempFile;

    User *_owner;
};
