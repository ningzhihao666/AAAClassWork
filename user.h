#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class UserInfo;

class User : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString nickname READ getNickname WRITE setNickname NOTIFY nicknameChanged)
    Q_PROPERTY(QString account READ getAccount CONSTANT)
    Q_PROPERTY(bool PremiunMembership READ isPremiunMembership NOTIFY isPremiunMembershipChanged)
    Q_PROPERTY(QString sign READ getSign WRITE setSign NOTIFY signChanged)
    // Q_PROPERTY(QString headportrait READ getheadportrait WRITE setheadportrait NOTIFY headportraitChanged)
    Q_PROPERTY(QString level READ getLevel WRITE setLevel NOTIFY levelChanged)
    Q_PROPERTY(QString followingCount READ getFollowingCount WRITE setFollowingCount NOTIFY followingCountChanged)
    Q_PROPERTY(QString fansCount READ getFansCount WRITE setFansCount NOTIFY fansCountChanged)
    Q_PROPERTY(QString likes READ getLikes WRITE setLikes NOTIFY likesChanged)

public:
    explicit User(QObject *parent = nullptr);
    User(const QString &nickName, const QString &account, const QString &password, QObject *parent = nullptr);
    ~User();

    QString getNickname();
    QString getAccount();
    QString getPassword();
    bool isPremiunMembership();
    QString getSign();
    QString getHeadportrait();
    QString getLevel();
    QString getFollowingCount();
    QString getFansCount();
    QString getLikes();
    bool getIsPremiunMembership();

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
    UserInfo *_uinfo = nullptr;

    void signalConnect();
};
