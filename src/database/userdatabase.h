#pragma once
#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QDateTime>
#include <memory>
#include <string>
#include <vector>
#include "../domain/user.h"

namespace infrastructure {

    class UserRepository : public QObject {
        Q_OBJECT

    public:
        static UserRepository* instance();
        static void destroy();

        // 数据库连接管理
        bool connectToDatabase();
        void closeDatabase();
        bool initDatabase();

        // 用户CRUD操作
        bool saveUser(domain::User* user);
        bool updateUser(domain::User* user);
        bool deleteUser(const std::string& userId);
        std::unique_ptr<domain::User> getUserById(const std::string& userId);
        std::unique_ptr<domain::User> getUserByAccount(const std::string& account);
        std::vector<std::unique_ptr<domain::User>> getAllUsers();

        // 关注关系操作
        bool addFollowRelation(const std::string& followerId,
                               const std::string& followingId);
        bool removeFollowRelation(const std::string& followerId,
                                  const std::string& followingId);
        std::vector<std::string> getFollowingIds(const std::string& userId);
        std::vector<std::string> getFollowerIds(const std::string& userId);
        bool isFollowing(const std::string& followerId,
                         const std::string& followingId);

        // 收藏操作
        bool addFavoriteVideo(const std::string& userId,
                              const std::string& videoId);
        bool removeFavoriteVideo(const std::string& userId,
                                 const std::string& videoId);
        std::vector<std::string> getFavoriteVideoIds(const std::string& userId);

        // 历史记录操作
        bool addWatchHistory(const std::string& userId,
                             const std::string& videoId,
                             const std::string& videoTitle,
                             const std::string& coverUrl);
        bool clearWatchHistory(const std::string& userId);
        std::vector<std::string> getWatchHistoryIds(const std::string& userId);

        // 点赞操作
        bool addLikedVideo(const std::string& userId,
                           const std::string& videoId);
        bool removeLikedVideo(const std::string& userId,
                              const std::string& videoId);
        std::vector<std::string> getLikedVideoIds(const std::string& userId);
        bool isVideoLikedByUser(const std::string& userId,
                                const std::string& videoId);

        //投币
        bool addVideoCoin(const std::string& userId,
                          const std::string& videoId);
        int getUserVideoCoinCount(const std::string& userId,
                                  const std::string& videoId);
        std::vector<std::pair<std::string, int>> getUserVideoCoins(const std::string& userId);

        // 统计
        int getUserCount();
        int getOnlineUserCount();

        // 验证
        bool validateLogin(const std::string& account,
                           const std::string& password);

        // 设置在线状态
        bool setUserOnline(const std::string& userId, bool online);

    private:
        UserRepository();
        ~UserRepository();

        static UserRepository* m_instance;
        QSqlDatabase m_db;

        // 数据库表创建
        bool createTables();
        bool createUsersTable();
        bool createFollowRelationsTable();
        bool createFavoritesTable();
        bool createHistoryTable();
        bool createVideoLikesTable();
        bool createVideoCoinsTable();

        // 辅助方法
        bool executeQuery(QSqlQuery& query, const QString& errorMessage = "");
        std::unique_ptr<domain::User> recordToUser(const QSqlRecord& record);
    };
}
