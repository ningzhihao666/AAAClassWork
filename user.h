//接口类


// 添加收藏
/*user.addFavoriteVideo("video_123")点击之后，video从数据库中找，

    // 添加观看历史
user.addWatchHistory("video_456")//点击之后，video从数据库中找，

    // 获取收藏列表
var favorites = user.favoriteVideos

      // 清空历史记录
user.clearWatchHistory()*/


#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include<QSqlRecord>
#include"vedio.h"

class UserInfo;

class User : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString password READ getPassword CONSTANT)  // 添加 password 属性
    Q_PROPERTY(QString nickname READ getNickname WRITE setNickname NOTIFY nicknameChanged)
    Q_PROPERTY(QString account READ getAccount CONSTANT)
    Q_PROPERTY(bool PremiunMembership READ isPremiunMembership NOTIFY isPremiunMembershipChanged)
    Q_PROPERTY(QString sign READ getSign WRITE setSign NOTIFY signChanged)
    Q_PROPERTY(QString headportrait READ getHeadportrait WRITE setHeadportrait NOTIFY headportraitChanged)
    Q_PROPERTY(QString level READ getLevel WRITE setLevel NOTIFY levelChanged)
    Q_PROPERTY(QString followingCount READ getFollowingCount WRITE setFollowingCount NOTIFY followingCountChanged)
    Q_PROPERTY(QString fansCount READ getFansCount WRITE setFansCount NOTIFY fansCountChanged)
    Q_PROPERTY(QString likes READ getLikes WRITE setLikes NOTIFY likesChanged)

    //!!!!!!!!!!!!!!!!!!!!!!!!!
    Q_PROPERTY(QStringList favoriteVideos READ getFavoriteVideos WRITE setFavoriteVideos NOTIFY favoriteVideosChanged)
    Q_PROPERTY(QStringList watchHistory READ getWatchHistory WRITE setWatchHistory NOTIFY watchHistoryChanged)

public:
    explicit User(QObject *parent = nullptr);
    User(const QString &nickName, const QString &account, const QString &password, QObject *parent = nullptr);
    User(const QSqlRecord &record, QObject *parent = nullptr);
    ~User();

    // 属性获取
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

    //!!!!!!!!!!!!!!!!!!!!!!!!
    QStringList getFavoriteVideos();
    QStringList getWatchHistory();

    //属性更新,实际是用userinfo中的属性设置
    void setPassword(const QString &password);
    void setAccount(const QString &account);
    void setNickname(const QString &nickname);
    void setSign(const QString &sign);
    void setHeadportrait(const QString &base64);
    void setLevel(const QString &level);
    void setFollowingCount(const QString &followingCount);
    void setFansCount(const QString &fansCount);
    void setLikes(const QString &likes);
    void setIsPremiunMembership(const bool isPremiunMembership);

    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    void setFavoriteVideos(const QStringList &favoriteVideos);
    void setWatchHistory(const QStringList &watchHistory);


    // 收藏和历史记录操作方法!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Q_INVOKABLE void addFavoriteVideo(const QString &videoId); //添加收藏
    Q_INVOKABLE void removeFavoriteVideo(const QString &videoId); //取消收藏
    Q_INVOKABLE void addWatchHistory(const QString &videoId); //添加历史记录
    Q_INVOKABLE void clearWatchHistory(); //清除所有历史记录

    // 关注关系操作方法
    Q_INVOKABLE bool follow(User *user);
    Q_INVOKABLE bool unfollow(User *user);
    Q_INVOKABLE bool isFollowing(User *user);
    Q_INVOKABLE bool isFollowedBy(User *user);
    Q_INVOKABLE QStringList getFollowingAccounts();
    Q_INVOKABLE QStringList getFollowerAccounts();

    // 视频收藏操作方法
    Q_INVOKABLE bool collectVideo(Vedio* video);
    Q_INVOKABLE bool uncollectVideo(Vedio* video);
    Q_INVOKABLE bool hasCollectedVideo(Vedio* video);
    Q_INVOKABLE QSet<Vedio*> getCollectedVideos();

    // 保持向后兼容的方法
    Q_INVOKABLE QStringList getFavoriteVideoIds();



signals:
    void passwordChanged();
    void accountChanged();
    void nicknameChanged();
    void signChanged();
    void headportraitChanged();
    void levelChanged();
    void followingCountChanged();
    void fansCountChanged();
    void likesChanged();
    void isPremiunMembershipChanged();

    // 新增信号
    void favoriteVideosChanged();
    void watchHistoryChanged();

    // 关注关系变化信号
    void followingChanged();
    void followersChanged();

private:
    UserInfo *_uinfo = nullptr;

    void signalConnect();
};
