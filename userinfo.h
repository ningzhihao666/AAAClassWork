//数据存储类
#pragma once

#include <QObject>
#include <QString>
#include<QSqlRecord>
//头像所需库
#include <QImage>
#include <QByteArray>
#include <QFile>
#include <QStandardPaths>
#include <QUrl>
#include <QDir>
#include <QDateTime>
#include <QSet>
#include"vedio.h"
#include"controllers/videomanager.h"
#include"controllers/eventController.h"


class User;

class UserInfo : public QObject
{
    Q_OBJECT
public:
    UserInfo(QString nickname,QString account,QString password, User *parent = nullptr);
    UserInfo(const QSqlRecord &record, User *parent = nullptr);
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

    QStringList getFavoriteVideos() { return m_favoriteVideos1; }
    QStringList getWatchHistory() { return m_watchHistory; }//!!!!!!!!!!!!!!!!!!!!!!!!

    // 关注关系相关方法
    QSet<UserInfo *> getFollowing() { return m_following; }
    QSet<UserInfo *> getFollowers() { return m_followers; }
    bool isFollowing(UserInfo *user) { return m_following.contains(user); }
    bool isFollowedBy(UserInfo *user) { return m_followers.contains(user); }


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

    // 收藏视频和历史记录相关方法!!!!!!!!!!!!!!!!!!!!!!!!
    void setFavoriteVideos(const QStringList &favoriteVideos);
    void setWatchHistory(const QStringList &watchHistory);
    void addFavoriteVideo(const QString &videoId);
    void removeFavoriteVideo(const QString &videoId);
    void addWatchHistory(const QString &videoId);
    void clearWatchHistory();

    // 关注关系操作方法
    bool follow(UserInfo *user);
    bool unfollow(UserInfo *user);
    void addFollower(UserInfo *user);
    void removeFollower(UserInfo *user);

    // 视频收藏相关方法 - 使用 Video 对象指针
    QSet<Vedio*> getCollectedVideos() { return m_collectedVideos; }
    bool hasCollectedVideo(Vedio* video) { return m_collectedVideos.contains(video); }

    // 收藏视频操作
    bool collectVideo(Vedio* video);
    bool uncollectVideo(Vedio* video);

    // 保持向后兼容的字符串列表方法
    QStringList getFavoriteVideoIds() const;



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

    void favoriteVideosChanged();
    void watchHistoryChanged();

    // 关注关系变化信号
    void followingChanged();
    void followersChanged();

    // 收藏
    void collectedVideosChanged();

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

    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    QStringList m_favoriteVideos1;  // 收藏的视频ID列表
    QStringList m_watchHistory;    // 观看历史的视频ID列表



    QSet<UserInfo *> m_following;  //我关注的人
    QSet<UserInfo *> m_followers;  //关注我的人


    QSet<Vedio *> m_collectedVideos;


    User *_owner;
};

