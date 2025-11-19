#pragma once
#include <QString>
#include <QMap>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include<QSqlRecord>
#include "user.h"
#include "vedio.h"

class DatabaseUser : public QObject
{
    Q_OBJECT

public:
    // 单例访问方法
    static DatabaseUser *instance();
    static void destroy();
    DatabaseUser();
    ~DatabaseUser();

    // 数据库连接管理
    bool connectToDatabase();
    void closeDatabase();

    // 用于账号检测与管理
    bool AddNetizen(User *user);
    bool RemoveNetizen(const QString &account);

    // 数据管理
    bool loadFromDatabase();
    bool saveToDatabase();
    bool initDatabase();
    Q_INVOKABLE bool registerUser(const QString& username, const QString& phone, const QString& password);
    Q_INVOKABLE User* getuser(const QString& phone);

    // 基本查询功能
    User* getUser(const QString &account);

    // 关注关系管理方法
    Q_INVOKABLE bool followUser(const QString &followerAccount, const QString &followingAccount);
    Q_INVOKABLE bool unfollowUser(const QString &followerAccount, const QString &followingAccount);
    Q_INVOKABLE QStringList getFollowingList(const QString &account);
    Q_INVOKABLE QStringList getFollowerList(const QString &account);
    Q_INVOKABLE bool isFollowing(const QString &followerAccount, const QString &followingAccount);


    // Q_INVOKABLE bool addFavoriteVideo(const QString &userAccount, const QString &videoId);
    // Q_INVOKABLE bool removeFavoriteVideo(const QString &userAccount, const QString &videoId);
    Q_INVOKABLE QStringList getFavoriteVideos(const QString &userAccount);
    //Q_INVOKABLE bool isVideoFavorite(const QString &userAccount, const QString &videoId);

    // 收藏视频方法 - 使用用户和视频对象
    Q_INVOKABLE bool addFavoriteVideo(User* user, Vedio* video);
    Q_INVOKABLE bool removeFavoriteVideo(User* user, Vedio* video);

    // 保持向后兼容的方法
    Q_INVOKABLE bool addFavoriteVideo(const QString &userAccount, const QString &videoId);
    Q_INVOKABLE bool removeFavoriteVideo(const QString &userAccount, const QString &videoId);
    // 添加观看历史记录
    Q_INVOKABLE bool addWatchHistory(const QString &userAccount, const QString &videoUrl,const QString &videoTitle, const QString &coverUrl);



private:
    // 单例访问指针
    static DatabaseUser *m_instance;

    // 数据库连接
    QSqlDatabase m_db;

    // 缓存管理
    QMap<QString, User *> m_users;

    // 辅助方法 - 将数据库记录转换为 user 类
    User* recordToUser(const QSqlRecord &record);

    // 更新用户信息到数据库
    bool updateUserInDatabase(User *user);

    // 创建数据库表
    bool createTables();

    // 执行 SQL 查询并检查错误
    bool executeQuery(QSqlQuery &query, const QString &errorMessage = "");
};
