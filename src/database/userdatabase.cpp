#include "userdatabase.h"
#include <QDebug>
#include <algorithm>

namespace infrastructure {

    UserRepository* UserRepository::m_instance = nullptr;

    UserRepository* UserRepository::instance() {
        if (!m_instance) {
            m_instance = new UserRepository();
        }
        return m_instance;
    }

    void UserRepository::destroy() {
        if (m_instance) {
            m_instance->closeDatabase();
            delete m_instance;
            m_instance = nullptr;
        }
    }

    UserRepository::UserRepository() : QObject() {
        // 初始化数据库连接
        m_db = QSqlDatabase::addDatabase("QMYSQL", "user_repository_connection");
        m_db.setHostName("cq-cdb-n6tlcxx5.sql.tencentcdb.com");
        m_db.setPort(20450);
        m_db.setDatabaseName("user");
        m_db.setUserName("root");
        m_db.setPassword("12345678lzh");
        m_db.setConnectOptions("MYSQL_OPT_CONNECT_TIMEOUT=15;MYSQL_OPT_READ_TIMEOUT=15;MYSQL_OPT_WRITE_TIMEOUT=15");
    }

    UserRepository::~UserRepository() {
        closeDatabase();
    }

    bool UserRepository::connectToDatabase() {
        if (m_db.isOpen()) {
            return true;
        }

        if (!m_db.open()) {
            qWarning() << "❌ 数据库连接失败:" << m_db.lastError().text();
            return false;
        }

        qDebug() << "✅ 数据库连接成功!";
        return true;
    }

    void UserRepository::closeDatabase() {
        if (m_db.isOpen()) {
            m_db.close();
            qDebug() << "🔴 数据库连接已关闭";
        }
    }

    bool UserRepository::initDatabase() {
        if (!connectToDatabase()) {
            return false;
        }

        return createTables();
    }

    bool UserRepository::createTables() {
        bool success = true;
        success = success && createUsersTable();
        success = success && createFollowRelationsTable();
        success = success && createFavoritesTable();
        success = success && createHistoryTable();
        success = success && createVideoLikesTable();
        success = success && createVideoCoinsTable();
        return success;
    }



    bool UserRepository::createUsersTable() {
        QSqlQuery query(m_db);
        QString sql = R"(
            CREATE TABLE IF NOT EXISTS users (
                id VARCHAR(255) PRIMARY KEY,
                account VARCHAR(255) UNIQUE NOT NULL,
                password VARCHAR(255) NOT NULL,
                nickname VARCHAR(255),
                avatar_url TEXT,
                signature TEXT,
                level VARCHAR(10) DEFAULT '1',
                following_count INT DEFAULT 0,
                fans_count INT DEFAULT 0,
                likes_count INT DEFAULT 0,
                video_count INT DEFAULT 0,
                coin_count INT DEFAULT 0,
                is_premium_member BOOLEAN DEFAULT FALSE,
                premium_expiry DATETIME,
                online BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_account (account),
                INDEX idx_online (online)
            )
        )";

        query.prepare(sql);
        return executeQuery(query, "创建用户表失败");
    }

    bool UserRepository::createFollowRelationsTable() {
        QSqlQuery query(m_db);
        QString sql = R"(
            CREATE TABLE IF NOT EXISTS follow_relations (
                id INT AUTO_INCREMENT PRIMARY KEY,
                follower_id VARCHAR(255),
                following_id VARCHAR(255),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
                FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE,
                UNIQUE KEY unique_follow (follower_id, following_id),
                INDEX idx_follower (follower_id),
                INDEX idx_following (following_id)
            )
        )";

        query.prepare(sql);
        return executeQuery(query, "创建关注关系表失败");
    }

    bool UserRepository::createFavoritesTable() {
        QSqlQuery query(m_db);
        QString sql = R"(
            CREATE TABLE IF NOT EXISTS favorites (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id VARCHAR(255),
                video_id VARCHAR(255),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                UNIQUE KEY unique_user_video (user_id, video_id),
                INDEX idx_user_id (user_id)
            )
        )";

        query.prepare(sql);
        return executeQuery(query, "创建收藏表失败");
    }

    bool UserRepository::createHistoryTable() {
        QSqlQuery query(m_db);
        QString sql = R"(
            CREATE TABLE IF NOT EXISTS watch_history (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id VARCHAR(255),
                video_id VARCHAR(255),
                video_title TEXT,
                video_cover TEXT,
                watch_time INT DEFAULT 0,
                last_watch_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                INDEX idx_user_id (user_id),
                INDEX idx_last_watch_at (last_watch_at)
            )
        )";

        query.prepare(sql);
        return executeQuery(query, "创建历史记录表失败");
    }

    bool UserRepository::createVideoLikesTable() {
        QSqlQuery query(m_db);
        QString sql = R"(
        CREATE TABLE IF NOT EXISTS video_likes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id VARCHAR(255),
            video_id VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            UNIQUE KEY unique_user_video (user_id, video_id),
            INDEX idx_user_id (user_id),
            INDEX idx_video_id (video_id)
        )
    )";

        query.prepare(sql);
        return executeQuery(query, "创建视频点赞表失败");
    }

    bool UserRepository::createVideoCoinsTable() {
        QSqlQuery query(m_db);
        QString sql = R"(
        CREATE TABLE IF NOT EXISTS video_coins (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id VARCHAR(255),
            video_id VARCHAR(255),
            coin_count INT DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            UNIQUE KEY unique_user_video (user_id, video_id),
            INDEX idx_user_id (user_id),
            INDEX idx_video_id (video_id)
        )
    )";

        query.prepare(sql);
        return executeQuery(query, "创建视频投币表失败");
    }

    bool UserRepository::executeQuery(QSqlQuery& query, const QString& errorMessage) {
        if (!query.exec()) {
            qWarning() << "❌" << errorMessage << ":" << query.lastError().text();
            return false;
        }
        return true;
    }

    bool UserRepository::saveUser(domain::User* user) {
        if (!user || !connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare(R"(
            INSERT INTO users (
                id, account, password, nickname, avatar_url, signature,
                level, following_count, fans_count, likes_count, video_count,
                coin_count, is_premium_member, premium_expiry, online
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        )");

        query.addBindValue(QString::fromStdString(user->id()));
        query.addBindValue(QString::fromStdString(user->account()));
        query.addBindValue(QString::fromStdString(user->password()));
        query.addBindValue(QString::fromStdString(user->nickname()));
        query.addBindValue(QString::fromStdString(user->avatarUrl()));
        query.addBindValue(QString::fromStdString(user->signature()));
        query.addBindValue(QString::fromStdString(user->level()));
        query.addBindValue(user->followingCount());
        query.addBindValue(user->fansCount());
        query.addBindValue(user->likesCount());
        query.addBindValue(user->videoCount());
        query.addBindValue(user->coinCount());
        query.addBindValue(user->isPremiumMember());

        // 设置默认的会员过期时间
        QDateTime premiumExpiry = QDateTime::currentDateTime().addMonths(1);
        query.addBindValue(premiumExpiry);

        query.addBindValue(false); // online

        return executeQuery(query, "保存用户失败");
    }

    bool UserRepository::updateUser(domain::User* user) {
        if (!user || !connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare(R"(
            UPDATE users SET
                nickname = ?,
                avatar_url = ?,
                signature = ?,
                level = ?,
                following_count = ?,
                fans_count = ?,
                likes_count = ?,
                video_count = ?,
                coin_count = ?,
                is_premium_member = ?,
                premium_expiry = ?,
                online = ?
            WHERE id = ?
        )");

        query.addBindValue(QString::fromStdString(user->nickname()));
        query.addBindValue(QString::fromStdString(user->avatarUrl()));
        query.addBindValue(QString::fromStdString(user->signature()));
        query.addBindValue(QString::fromStdString(user->level()));
        query.addBindValue(user->followingCount());
        query.addBindValue(user->fansCount());
        query.addBindValue(user->likesCount());
        query.addBindValue(user->videoCount());
        query.addBindValue(user->coinCount());
        query.addBindValue(user->isPremiumMember());

        // 设置默认的会员过期时间
        QDateTime premiumExpiry = QDateTime::currentDateTime().addMonths(1);
        query.addBindValue(premiumExpiry);

        query.addBindValue(false); // online
        query.addBindValue(QString::fromStdString(user->id()));

        return executeQuery(query, "更新用户失败");
    }

    bool UserRepository::deleteUser(const std::string& userId) {
        if (!connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("DELETE FROM users WHERE id = ?");
        query.addBindValue(QString::fromStdString(userId));

        return executeQuery(query, "删除用户失败");
    }

    std::unique_ptr<domain::User> UserRepository::getUserById(const std::string& userId) {
        if (!connectToDatabase()) {
            return nullptr;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT * FROM users WHERE id = ?");
        query.addBindValue(QString::fromStdString(userId));

        if (!executeQuery(query, "获取用户失败") || !query.next()) {
            return nullptr;
        }

        auto user = recordToUser(query.record());
        if (!user) {
            return nullptr;
        }

        // 加载关注关系
        auto followingIds = getFollowingIds(userId);
        for (const auto& id : followingIds) {
            user->follow(id);
        }

        // 加载粉丝关系
        auto followerIds = getFollowerIds(userId);
        for (const auto& id : followerIds) {
            user->addFollowerId(id);
        }

        // 加载收藏
        auto favoriteIds = getFavoriteVideoIds(userId);
        for (const auto& id : favoriteIds) {
            user->addFavoriteVideo(id);
        }

        // 加载历史记录
        auto historyIds = getWatchHistoryIds(userId);
        for (const auto& id : historyIds) {
            user->addWatchHistory(id);
        }

        //加载点赞关系
        auto likedIds = getLikedVideoIds(userId);
        for (const auto& id : likedIds) {
            user->addLikedVideo(id);
        }

        //加载投币记录
        auto coinRecords = getUserVideoCoins(userId);
        for (const auto& pair : coinRecords) {
            user->setVideoCoinCount(pair.first, pair.second);
        }

        return user;
    }

    std::unique_ptr<domain::User> UserRepository::getUserByAccount(const std::string& account) {
        if (!connectToDatabase()) {
            return nullptr;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT * FROM users WHERE account = ?");
        query.addBindValue(QString::fromStdString(account));

        if (!executeQuery(query, "获取用户失败") || !query.next()) {
            return nullptr;
        }

        auto user = recordToUser(query.record());
        if (!user) {
            return nullptr;
        }

        std::string userId = user->id();

        //加载点赞关系
        auto likedIds = getLikedVideoIds(userId);
        for (const auto& id : likedIds) {
            user->addLikedVideo(id);
        }

        // 加载关注关系
        auto followingIds = getFollowingIds(userId);
        for (const auto& id : followingIds) {
            user->follow(id);
        }

        // 加载粉丝关系
        auto followerIds = getFollowerIds(userId);
        for (const auto& id : followerIds) {
            user->addFollowerId(id);
        }

        // 加载收藏
        auto favoriteIds = getFavoriteVideoIds(userId);
        for (const auto& id : favoriteIds) {
            user->addFavoriteVideo(id);
        }

        // 加载历史记录
        auto historyIds = getWatchHistoryIds(userId);
        for (const auto& id : historyIds) {
            user->addWatchHistory(id);
        }

        // 加载投币记录
        auto coinRecords = getUserVideoCoins(userId);
        for (const auto& pair : coinRecords) {
            user->setVideoCoinCount(pair.first, pair.second);
        }

        return user;
    }

    std::vector<std::unique_ptr<domain::User>> UserRepository::getAllUsers() {
        std::vector<std::unique_ptr<domain::User>> users;

        if (!connectToDatabase()) {
            return users;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT * FROM users ORDER BY created_at DESC");

        if (executeQuery(query, "获取所有用户失败")) {
            while (query.next()) {
                auto user = recordToUser(query.record());
                if (user) {
                    std::string userId = user->id();

                    // 加载点赞
                    auto likedIds = getLikedVideoIds(userId);
                    for (const auto& id : likedIds) {
                        user->addLikedVideo(id);
                    }

                    // 加载关注关系
                    auto followingIds = getFollowingIds(userId);
                    for (const auto& id : followingIds) {
                        user->follow(id);
                    }

                    // 加载粉丝关系
                    auto followerIds = getFollowerIds(userId);
                    for (const auto& id : followerIds) {
                        user->addFollowerId(id);
                    }

                    // 加载收藏
                    auto favoriteIds = getFavoriteVideoIds(userId);
                    for (const auto& id : favoriteIds) {
                        user->addFavoriteVideo(id);
                    }

                    // 加载历史记录
                    auto historyIds = getWatchHistoryIds(userId);
                    for (const auto& id : historyIds) {
                        user->addWatchHistory(id);
                    }

                    users.push_back(std::move(user));
                }
            }
        }

        return users;
    }

    // 实现投币操作方法
    bool UserRepository::addVideoCoin(const std::string& userId,
                                      const std::string& videoId) {
        if (!connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);

        // 先检查是否已经有记录
        query.prepare("SELECT coin_count FROM video_coins WHERE user_id = ? AND video_id = ?");
        query.addBindValue(QString::fromStdString(userId));
        query.addBindValue(QString::fromStdString(videoId));

        if (executeQuery(query, "查询投币记录失败") && query.next()) {
            // 已有记录，增加投币数量
            QSqlQuery updateQuery(m_db);
            updateQuery.prepare("UPDATE video_coins SET coin_count = coin_count + 1 WHERE user_id = ? AND video_id = ?");
            updateQuery.addBindValue(QString::fromStdString(userId));
            updateQuery.addBindValue(QString::fromStdString(videoId));

            return executeQuery(updateQuery, "更新投币记录失败");
        } else {
            // 没有记录，插入新记录（默认投币1个）
            QSqlQuery insertQuery(m_db);
            insertQuery.prepare("INSERT INTO video_coins (user_id, video_id) VALUES (?, ?)");
            insertQuery.addBindValue(QString::fromStdString(userId));
            insertQuery.addBindValue(QString::fromStdString(videoId));

            return executeQuery(insertQuery, "插入投币记录失败");
        }
    }

    int UserRepository::getUserVideoCoinCount(const std::string& userId,
                                              const std::string& videoId) {
        if (!connectToDatabase()) {
            return 0;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT coin_count FROM video_coins WHERE user_id = ? AND video_id = ?");
        query.addBindValue(QString::fromStdString(userId));
        query.addBindValue(QString::fromStdString(videoId));

        if (executeQuery(query, "获取用户视频投币数失败") && query.next()) {
            return query.value(0).toInt();
        }

        return 0;
    }

    std::vector<std::pair<std::string, int>> UserRepository::getUserVideoCoins(const std::string& userId) {
        std::vector<std::pair<std::string, int>> coins;

        if (!connectToDatabase()) {
            return coins;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT video_id, coin_count FROM video_coins WHERE user_id = ?");
        query.addBindValue(QString::fromStdString(userId));

        if (executeQuery(query, "获取用户投币记录失败")) {
            while (query.next()) {
                std::string videoId = query.value(0).toString().toStdString();
                int count = query.value(1).toInt();
                coins.emplace_back(videoId, count);
            }
        }

        return coins;
    }

    bool UserRepository::addLikedVideo(const std::string& userId,
                                       const std::string& videoId) {
        if (!connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("INSERT INTO video_likes (user_id, video_id) VALUES (?, ?)");
        query.addBindValue(QString::fromStdString(userId));
        query.addBindValue(QString::fromStdString(videoId));

        return executeQuery(query, "添加点赞失败");
    }

    bool UserRepository::removeLikedVideo(const std::string& userId,
                                          const std::string& videoId) {
        if (!connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("DELETE FROM video_likes WHERE user_id = ? AND video_id = ?");
        query.addBindValue(QString::fromStdString(userId));
        query.addBindValue(QString::fromStdString(videoId));

        return executeQuery(query, "删除点赞失败");
    }

    bool UserRepository::addFollowRelation(const std::string& followerId,
                                           const std::string& followingId) {
        if (!connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("INSERT INTO follow_relations (follower_id, following_id) VALUES (?, ?)");
        query.addBindValue(QString::fromStdString(followerId));
        query.addBindValue(QString::fromStdString(followingId));

        return executeQuery(query, "添加关注关系失败");
    }

    bool UserRepository::removeFollowRelation(const std::string& followerId,
                                              const std::string& followingId) {
        if (!connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("DELETE FROM follow_relations WHERE follower_id = ? AND following_id = ?");
        query.addBindValue(QString::fromStdString(followerId));
        query.addBindValue(QString::fromStdString(followingId));

        return executeQuery(query, "删除关注关系失败");
    }

    std::vector<std::string> UserRepository::getLikedVideoIds(const std::string& userId) {
        std::vector<std::string> likedIds;

        if (!connectToDatabase()) {
            return likedIds;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT video_id FROM video_likes WHERE user_id = ? ORDER BY created_at DESC");
        query.addBindValue(QString::fromStdString(userId));

        if (executeQuery(query, "获取点赞列表失败")) {
            while (query.next()) {
                likedIds.push_back(query.value(0).toString().toStdString());
            }
        }

        return likedIds;
    }

    std::vector<std::string> UserRepository::getFollowingIds(const std::string& userId) {
        std::vector<std::string> followingIds;

        if (!connectToDatabase()) {
            return followingIds;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT following_id FROM follow_relations WHERE follower_id = ?");
        query.addBindValue(QString::fromStdString(userId));

        if (executeQuery(query, "获取关注列表失败")) {
            while (query.next()) {
                followingIds.push_back(query.value(0).toString().toStdString());
            }
        }

        return followingIds;
    }

    std::vector<std::string> UserRepository::getFollowerIds(const std::string& userId) {
        std::vector<std::string> followerIds;

        if (!connectToDatabase()) {
            return followerIds;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT follower_id FROM follow_relations WHERE following_id = ?");
        query.addBindValue(QString::fromStdString(userId));

        if (executeQuery(query, "获取粉丝列表失败")) {
            while (query.next()) {
                followerIds.push_back(query.value(0).toString().toStdString());
            }
        }

        return followerIds;
    }

    bool UserRepository::isVideoLikedByUser(const std::string& userId,
                                            const std::string& videoId) {
        if (!connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT COUNT(*) FROM video_likes WHERE user_id = ? AND video_id = ?");
        query.addBindValue(QString::fromStdString(userId));
        query.addBindValue(QString::fromStdString(videoId));

        if (executeQuery(query, "检查点赞关系失败") && query.next()) {
            return query.value(0).toInt() > 0;
        }

        return false;
    }


    bool UserRepository::isFollowing(const std::string& followerId,
                                     const std::string& followingId) {
        if (!connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT COUNT(*) FROM follow_relations WHERE follower_id = ? AND following_id = ?");
        query.addBindValue(QString::fromStdString(followerId));
        query.addBindValue(QString::fromStdString(followingId));

        if (executeQuery(query, "检查关注关系失败") && query.next()) {
            return query.value(0).toInt() > 0;
        }

        return false;
    }

    bool UserRepository::addFavoriteVideo(const std::string& userId,
                                          const std::string& videoId) {
        if (!connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("INSERT INTO favorites (user_id, video_id) VALUES (?, ?)");
        query.addBindValue(QString::fromStdString(userId));
        query.addBindValue(QString::fromStdString(videoId));

        return executeQuery(query, "添加收藏失败");
    }

    bool UserRepository::removeFavoriteVideo(const std::string& userId,
                                             const std::string& videoId) {
        if (!connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("DELETE FROM favorites WHERE user_id = ? AND video_id = ?");
        query.addBindValue(QString::fromStdString(userId));
        query.addBindValue(QString::fromStdString(videoId));

        return executeQuery(query, "删除收藏失败");
    }

    std::vector<std::string> UserRepository::getFavoriteVideoIds(const std::string& userId) {
        std::vector<std::string> favoriteIds;

        if (!connectToDatabase()) {
            return favoriteIds;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT video_id FROM favorites WHERE user_id = ? ORDER BY created_at DESC");
        query.addBindValue(QString::fromStdString(userId));

        if (executeQuery(query, "获取收藏列表失败")) {
            while (query.next()) {
                favoriteIds.push_back(query.value(0).toString().toStdString());
            }
        }

        return favoriteIds;
    }

    bool UserRepository::addWatchHistory(const std::string& userId,
                                         const std::string& videoId,
                                         const std::string& videoTitle,
                                         const std::string& coverUrl) {
        if (!connectToDatabase()) {
            return false;
        }

        // 先检查是否存在
        QSqlQuery checkQuery(m_db);
        checkQuery.prepare("SELECT id FROM watch_history WHERE user_id = ? AND video_id = ?");
        checkQuery.addBindValue(QString::fromStdString(userId));
        checkQuery.addBindValue(QString::fromStdString(videoId));

        if (executeQuery(checkQuery, "检查历史记录失败") && checkQuery.next()) {
            // 更新现有记录
            QSqlQuery updateQuery(m_db);
            updateQuery.prepare("UPDATE watch_history SET last_watch_at = CURRENT_TIMESTAMP WHERE user_id = ? AND video_id = ?");
            updateQuery.addBindValue(QString::fromStdString(userId));
            updateQuery.addBindValue(QString::fromStdString(videoId));
            return executeQuery(updateQuery, "更新历史记录失败");
        } else {
            // 插入新记录
            QSqlQuery insertQuery(m_db);
            insertQuery.prepare("INSERT INTO watch_history (user_id, video_id, video_title, video_cover) VALUES (?, ?, ?, ?)");
            insertQuery.addBindValue(QString::fromStdString(userId));
            insertQuery.addBindValue(QString::fromStdString(videoId));
            insertQuery.addBindValue(QString::fromStdString(videoTitle));
            insertQuery.addBindValue(QString::fromStdString(coverUrl));
            return executeQuery(insertQuery, "添加历史记录失败");
        }
    }

    bool UserRepository::clearWatchHistory(const std::string& userId) {
        if (!connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("DELETE FROM watch_history WHERE user_id = ?");
        query.addBindValue(QString::fromStdString(userId));

        return executeQuery(query, "清空历史记录失败");
    }

    std::vector<std::string> UserRepository::getWatchHistoryIds(const std::string& userId) {
        std::vector<std::string> historyIds;

        if (!connectToDatabase()) {
            return historyIds;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT video_id FROM watch_history WHERE user_id = ? ORDER BY last_watch_at DESC LIMIT 100");
        query.addBindValue(QString::fromStdString(userId));

        if (executeQuery(query, "获取历史记录失败")) {
            while (query.next()) {
                historyIds.push_back(query.value(0).toString().toStdString());
            }
        }

        return historyIds;
    }

    int UserRepository::getUserCount() {
        if (!connectToDatabase()) {
            return 0;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT COUNT(*) FROM users");

        if (executeQuery(query, "获取用户数量失败") && query.next()) {
            return query.value(0).toInt();
        }

        return 0;
    }

    int UserRepository::getOnlineUserCount() {
        if (!connectToDatabase()) {
            return 0;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT COUNT(*) FROM users WHERE online = TRUE");

        if (executeQuery(query, "获取在线用户数量失败") && query.next()) {
            return query.value(0).toInt();
        }

        return 0;
    }

    bool UserRepository::validateLogin(const std::string& account,
                                       const std::string& password) {
        if (!connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT COUNT(*) FROM users WHERE account = ? AND password = ?");
        query.addBindValue(QString::fromStdString(account));
        query.addBindValue(QString::fromStdString(password));

        if (executeQuery(query, "验证登录失败") && query.next()) {
            return query.value(0).toInt() > 0;
        }

        return false;
    }

    bool UserRepository::setUserOnline(const std::string& userId, bool online) {
        if (!connectToDatabase()) {
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("UPDATE users SET online = ? WHERE id = ?");
        query.addBindValue(online);
        query.addBindValue(QString::fromStdString(userId));

        return executeQuery(query, "设置用户在线状态失败");
    }

    std::unique_ptr<domain::User> UserRepository::recordToUser(const QSqlRecord& record) {
        if (record.isEmpty()) {
            return nullptr;
        }

        domain::User::UserInfo info;
        info.account = record.value("account").toString().toStdString();
        info.password = record.value("password").toString().toStdString();
        info.nickname = record.value("nickname").toString().toStdString();
        info.avatarUrl = record.value("avatar_url").toString().toStdString();
        info.signature = record.value("signature").toString().toStdString();

        auto user = domain::User::createLocalUser(info);
        if (!user) {
            return nullptr;
        }

        // 设置从数据库读取的字段
        user->setId(record.value("id").toString().toStdString());
        user->setLevel(record.value("level").toString().toStdString());
        user->setFollowingCount(record.value("following_count").toInt());
        user->setFansCount(record.value("fans_count").toInt());
        user->setLikesCount(record.value("likes_count").toInt());
        user->setVideoCount(record.value("video_count").toInt());
        user->setCoinCount(record.value("coin_count").toInt());
        user->setPremiumMember(record.value("is_premium_member").toBool());

        // 设置会员过期时间
        QDateTime premiumExpiry = record.value("premium_expiry").toDateTime();
        auto timePoint = std::chrono::system_clock::from_time_t(premiumExpiry.toSecsSinceEpoch());
        user->setPremiumExpiry(timePoint);

        return user;
    }
}
