/// databaseuser.cpp - 使用 Qt SQL 直接连接数据库
#include <QDateTime>
#include <QDebug>
#include "databaseuser.h"

DatabaseUser *DatabaseUser::m_instance = nullptr;

DatabaseUser *DatabaseUser::instance()
{
    if (!m_instance) {
        m_instance = new DatabaseUser();
    }
    return m_instance;
}

void DatabaseUser::destroy()
{
    if (m_instance) {
        m_instance->closeDatabase();
        delete m_instance;
        m_instance = nullptr;
    }
}

DatabaseUser::DatabaseUser() : QObject()
{
    // 初始化数据库连接
    m_db = QSqlDatabase::addDatabase("QMYSQL", "user_connection");
    m_db.setHostName("cq-cdb-82wznfkj.sql.tencentcdb.com");
    m_db.setPort(22290);
    m_db.setDatabaseName("user");
    m_db.setUserName("root");
    m_db.setPassword("12345678n");
    m_db.setConnectOptions("MYSQL_OPT_CONNECT_TIMEOUT=15;MYSQL_OPT_READ_TIMEOUT=15;MYSQL_OPT_WRITE_TIMEOUT=15");
}

DatabaseUser::~DatabaseUser()
{
    closeDatabase();
}

bool DatabaseUser::connectToDatabase()
{
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

void DatabaseUser::closeDatabase()
{
    if (m_db.isOpen()) {
        m_db.close();
        qDebug() << "🔴 数据库连接已关闭";
    }
}

bool DatabaseUser::initDatabase()
{
    if (!connectToDatabase()) {
        return false;
    }

    return createTables();
}

bool DatabaseUser::createTables()
{
    // 创建用户表
    QSqlQuery query(m_db);

    QString createUsersTable = R"(
        CREATE TABLE IF NOT EXISTS users (
            account VARCHAR(255) PRIMARY KEY,
            nickname TEXT,
            password TEXT,
            headportrait TEXT,
            sign TEXT,
            level TEXT,
            followingCount TEXT,
            fansCount TEXT,
            likes TEXT,
            isPremiunMembership BOOLEAN DEFAULT FALSE,
            online BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    )";

    query.prepare(createUsersTable);
    if (!executeQuery(query, "创建用户表失败")) {
        return false;
    }

    qDebug() << "✅ users表创建/检查完成";

    // 创建关注关系表
    QString createFollowTable = R"(
        CREATE TABLE IF NOT EXISTS follow_relations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            follower_account VARCHAR(255),
            following_account VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (follower_account) REFERENCES users(account) ON DELETE CASCADE,
            FOREIGN KEY (following_account) REFERENCES users(account) ON DELETE CASCADE,
            UNIQUE KEY unique_follow (follower_account, following_account)
        )
    )";

    query.prepare(createFollowTable);
    if (!executeQuery(query, "创建关注关系表失败")) {
        return false;
    }

    qDebug() << "✅ follow_relations表创建/检查完成";

    // 创建历史记录表
    QString createHistoryTable = R"(
        CREATE TABLE IF NOT EXISTS history (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_account VARCHAR(255),
            video_id VARCHAR(255),
            video_title TEXT,
            video_cover TEXT,
            video_duration INT,
            watch_time INT DEFAULT 0,
            last_watch_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_account) REFERENCES users(account) ON DELETE CASCADE,
            INDEX idx_user_account (user_account),
            INDEX idx_last_watch_time (last_watch_time)
        )
    )";

    query.prepare(createHistoryTable);
    if (!executeQuery(query, "创建历史记录表失败")) {
        return false;
    }

    qDebug() << "✅ history表创建/检查完成";

    // 创建收藏表
    QString createFavoritesTable = R"(
        CREATE TABLE IF NOT EXISTS favorites (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_account VARCHAR(255),
            video_id VARCHAR(255),
            video_title TEXT,
            video_cover TEXT,
            video_duration INT,
            collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            folder_id INT DEFAULT 0 COMMENT '收藏夹ID，0为默认收藏夹',
            FOREIGN KEY (user_account) REFERENCES users(account) ON DELETE CASCADE,
            INDEX idx_user_account (user_account),
            INDEX idx_folder_id (folder_id),
            UNIQUE KEY unique_user_video (user_account, video_id, folder_id)
        )
    )";

    query.prepare(createFavoritesTable);
    if (!executeQuery(query, "创建收藏表失败")) {
        return false;
    }

    qDebug() << "✅ favorites表创建/检查完成";
    return true;
}

bool DatabaseUser::executeQuery(QSqlQuery &query, const QString &errorMessage)
{
    if (!query.exec()) {
        qWarning() << "❌" << errorMessage << ":" << query.lastError().text();
        return false;
    }
    return true;
}

bool DatabaseUser::loadFromDatabase()
{
    if (!connectToDatabase()) {
        return false;
    }

    // 清空当前内存缓存
    qDeleteAll(m_users);
    m_users.clear();

    QSqlQuery query(m_db);
    query.prepare("SELECT * FROM users");

    if (!executeQuery(query, "加载用户数据失败")) {
        return false;
    }

    int loadedCount = 0;
    while (query.next()) {
        QSqlRecord record = query.record();
        QString account = record.value("account").toString();
        QString followingCount = record.value("followingCount").toString();

        // 添加调试输出
        // if (account == "account123") {
        //     qDebug() << "🔍 DEBUG - account123 数据库记录:";
        //     qDebug() << "  followingCount:" << followingCount;
        //     qDebug() << "  level:" << record.value("level").toString();
        //     qDebug() << "  fansCount:" << record.value("fansCount").toString();
        // }
        User *user = recordToUser(query.record());
        if (user) {
            m_users.insert(user->getAccount(), user);
            loadedCount++;
        }
    }

    qDebug() << "✅ 从数据库加载了" << loadedCount << "个用户";

    query.prepare("SELECT user_account, video_id FROM favorites");
    if (executeQuery(query, "加载收藏关系失败")) {
        int favoriteCount = 0;
        while (query.next()) {
            QString userAccount = query.value("user_account").toString();
            QString videoId = query.value("video_id").toString();

            User *user = getUser(userAccount);
            if (user) {
                user->addFavoriteVideo(videoId);
                favoriteCount++;
            }
        }
        qDebug() << "✅ 从数据库加载了" << favoriteCount << "个视频收藏关系";
    }

    // 新增：加载关注关系
    query.prepare("SELECT follower_account, following_account FROM follow_relations");
    if (executeQuery(query, "加载关注关系失败")) {
        int followCount = 0;
        while (query.next()) {
            QString followerAccount = query.value("follower_account").toString();
            QString followingAccount = query.value("following_account").toString();

            User *follower = getUser(followerAccount);
            User *following = getUser(followingAccount);



            if (follower && following) {
                // 在内存中建立关注关系（不触发数据库更新）

                // // 添加调试
                // if (followerAccount == "account123") {
                //     qDebug() << "🔍 DEBUG - 加载关注关系: account123 ->" << followingAccount;
                // }
                follower->follow(following);
                followCount++;
            }
        }
        qDebug() << "✅ 从数据库加载了" << followCount << "个关注关系";
    }

    return true;
}

User* DatabaseUser::getUser(const QString &account)
{
    return m_users.value(account, nullptr);
}

bool DatabaseUser::AddNetizen(User *user)
{
    if (!user || m_users.contains(user->getAccount())) {
        qWarning() << "⚠️ 用户已存在或用户对象为空";
        return false;
    }

    if (!connectToDatabase()) {
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO users (account, nickname, password, sign, level, followingCount, fansCount, likes, isPremiunMembership, online)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    )");

    query.addBindValue(user->getAccount());
    query.addBindValue(user->getNickname());
    query.addBindValue(user->getPassword());
    query.addBindValue(user->getSign());
    query.addBindValue(user->getLevel());
    query.addBindValue(user->getFollowingCount());
    query.addBindValue(user->getFansCount());
    query.addBindValue(user->getLikes());
    query.addBindValue(user->isPremiunMembership());
    query.addBindValue(false);

    if (!executeQuery(query, "添加用户失败")) {
        return false;
    }

    m_users.insert(user->getAccount(), user);
    qDebug() << "✅ 用户" << user->getNickname() << "(" << user->getAccount() << ") 添加成功";
    return true;
}

bool DatabaseUser::RemoveNetizen(const QString &account)
{
    if (!m_users.contains(account)) {
        qWarning() << "⚠️ 用户不存在:" << account;
        return false;
    }

    if (!connectToDatabase()) {
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare("DELETE FROM users WHERE account = ?");
    query.addBindValue(account);

    if (!executeQuery(query, "删除用户失败")) {
        return false;
    }

    User *user = m_users.take(account);
    delete user;
    qDebug() << "✅ 用户" << account << "删除成功";
    return true;
}

User* DatabaseUser::recordToUser(const QSqlRecord &record)
{
    if (record.isEmpty()) {
        return nullptr;
    }

    // QString account = record.value("account").toString();
    // QString nickname = record.value("nickname").toString();
    // QString password = record.value("password").toString();

    // User *user = new User(nickname, account, password);
    // user->setSign(record.value("sign").toString());
    // user->setHeadportrait(record.value("headportrait").toString());
    // user->setLevel(record.value("level").toString());
    // user->setFollowingCount(record.value("followingCount").toString());
    // user->setFansCount(record.value("fansCount").toString());
    // user->setLikes(record.value("likes").toString());
    // user->setIsPremiunMembership(record.value("isPremiunMembership").toBool());
    User *user = new User(record, nullptr);

    // QString account = record.value("account").toString();
    // if (account == "account123") {
    //     qDebug() << "🔍 DEBUG - recordToUser 创建 account123 用户:";
    //     qDebug() << "  数据库 followingCount:" << record.value("followingCount").toString();
    //     qDebug() << "  用户对象 followingCount:" << user->getFollowingCount();
    // }

    return user;
}

bool DatabaseUser::registerUser(const QString &username, const QString &phone, const QString &password)
{
    DatabaseUser *db = DatabaseUser::instance();
    User *newUser = new User(username, phone, password);

    if (db->AddNetizen(newUser)) {
        return true;
    } else {
        delete newUser;
        return false;
    }
}

User* DatabaseUser::getuser(const QString& phone)
{
    DatabaseUser *db = DatabaseUser::instance();
    return db->getUser(phone);
}

// 关注用户
bool DatabaseUser::followUser(const QString &followerAccount, const QString &followingAccount)
{
    if (followerAccount == followingAccount) {
        qWarning() << "❌ 不能关注自己";
        return false;
    }

    User *follower = getUser(followerAccount);
    User *following = getUser(followingAccount);

    if (!follower || !following) {
        qWarning() << "❌ 用户不存在:" << followerAccount << "或" << followingAccount;
        return false;
    }

    if (!connectToDatabase()) {
        return false;
    }

    // 开始事务
    m_db.transaction();

    try {
        // 在内存中建立关注关系
        if (!follower->follow(following)) {
            throw std::runtime_error("内存关注失败");
        }

        // 插入关注关系到数据库
        QSqlQuery query(m_db);
        query.prepare("INSERT INTO follow_relations (follower_account, following_account) VALUES (?, ?)");
        query.addBindValue(followerAccount);
        query.addBindValue(followingAccount);

        if (!executeQuery(query, "插入关注关系失败")) {
            throw std::runtime_error("数据库关注失败");
        }

        // 更新关注者的关注数
        query.prepare("UPDATE users SET followingCount = ? WHERE account = ?");
        query.addBindValue(follower->getFollowingCount());
        query.addBindValue(followerAccount);

        if (!executeQuery(query, "更新关注数失败")) {
            throw std::runtime_error("更新关注数失败");
        }

        // 更新被关注者的粉丝数
        query.prepare("UPDATE users SET fansCount = ? WHERE account = ?");
        query.addBindValue(following->getFansCount());
        query.addBindValue(followingAccount);

        if (!executeQuery(query, "更新粉丝数失败")) {
            throw std::runtime_error("更新粉丝数失败");
        }

        // 提交事务
        if (!m_db.commit()) {
            throw std::runtime_error("提交事务失败");
        }

        qDebug() << "✅" << followerAccount << "关注了" << followingAccount;
        return true;

    } catch (const std::exception &e) {
        // 回滚事务
        m_db.rollback();
        // 回滚内存中的关系
        follower->unfollow(following);
        qWarning() << "❌ 关注操作失败:" << e.what();
        return false;
    }
}

// 取消关注
bool DatabaseUser::unfollowUser(const QString &followerAccount, const QString &followingAccount)
{
    User *follower = getUser(followerAccount);
    User *following = getUser(followingAccount);

    if (!follower || !following) {
        return false;
    }

    if (!connectToDatabase()) {
        return false;
    }

    // 开始事务
    m_db.transaction();

    try {
        // 在内存中取消关注关系
        if (!follower->unfollow(following)) {
            throw std::runtime_error("内存取消关注失败");
        }

        // 从数据库删除关注关系
        QSqlQuery query(m_db);
        query.prepare("DELETE FROM follow_relations WHERE follower_account = ? AND following_account = ?");
        query.addBindValue(followerAccount);
        query.addBindValue(followingAccount);

        if (!executeQuery(query, "删除关注关系失败")) {
            throw std::runtime_error("数据库取消关注失败");
        }

        // 更新关注者的关注数
        query.prepare("UPDATE users SET followingCount = ? WHERE account = ?");
        query.addBindValue(follower->getFollowingCount());
        query.addBindValue(followerAccount);

        if (!executeQuery(query, "更新关注数失败")) {
            throw std::runtime_error("更新关注数失败");
        }

        // 更新被关注者的粉丝数
        query.prepare("UPDATE users SET fansCount = ? WHERE account = ?");
        query.addBindValue(following->getFansCount());
        query.addBindValue(followingAccount);

        if (!executeQuery(query, "更新粉丝数失败")) {
            throw std::runtime_error("更新粉丝数失败");
        }

        // 提交事务
        if (!m_db.commit()) {
            throw std::runtime_error("提交事务失败");
        }

        qDebug() << "✅" << followerAccount << "取消关注" << followingAccount;
        return true;

    } catch (const std::exception &e) {
        // 回滚事务
        m_db.rollback();
        // 回滚内存中的关系
        follower->follow(following);
        qWarning() << "❌ 取消关注操作失败:" << e.what();
        return false;
    }
}

// 获取关注列表
QStringList DatabaseUser::getFollowingList(const QString &account)
{
    User *user = getUser(account);
    if (user) {
        return user->getFollowingAccounts();
    }
    return QStringList();
}

// 获取粉丝列表
QStringList DatabaseUser::getFollowerList(const QString &account)
{
    QStringList followers;

    if (!connectToDatabase()) {
        return followers;
    }

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT follower_account
        FROM follow_relations
        WHERE following_account = ?
    )");
    query.addBindValue(account);

    if (!executeQuery(query, "获取粉丝列表失败")) {
        return followers;
    }

    while (query.next()) {
        followers.append(query.value(0).toString());
    }

    return followers;
}

// 检查是否已关注
bool DatabaseUser::isFollowing(const QString &followerAccount, const QString &followingAccount)
{
    User *follower = getUser(followerAccount);
    User *following = getUser(followingAccount);

    if (follower && following) {
        return follower->isFollowing(following);
    }
    return false;
}

// 更新用户信息到数据库
bool DatabaseUser::updateUserInDatabase(User *user)
{
    if (!user) {
        return false;
    }

    if (!connectToDatabase()) {
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE users
        SET nickname = ?, sign = ?, level = ?, followingCount = ?, fansCount = ?, likes = ?, isPremiunMembership = ?
        WHERE account = ?
    )");

    query.addBindValue(user->getNickname());
    query.addBindValue(user->getSign());
    query.addBindValue(user->getLevel());
    query.addBindValue(user->getFollowingCount());
    query.addBindValue(user->getFansCount());
    query.addBindValue(user->getLikes());
    query.addBindValue(user->isPremiunMembership());
    query.addBindValue(user->getAccount());

    if (!executeQuery(query, "更新用户信息失败")) {
        return false;
    }

    qDebug() << "✅ 用户" << user->getAccount() << "信息更新成功";
    return true;
}

// 收藏视频方法
/*bool DatabaseUser::addFavoriteVideo(const QString &userAccount, const QString &videoId)
{
    User *user = getUser(userAccount);
    if (!user) {
        qWarning() << "❌ 用户不存在:" << userAccount;
        return false;
    }

    if (!connectToDatabase()) {
        return false;
    }

    // 开始事务
    m_db.transaction();

    try {
        // 在内存中添加收藏
        user->addFavoriteVideo(videoId);

        // 插入收藏关系到数据库
        QSqlQuery query(m_db);
        query.prepare("INSERT INTO favorites (user_account, video_id) VALUES (?, ?)");
        query.addBindValue(userAccount);
        query.addBindValue(videoId);

        if (!executeQuery(query, "插入收藏关系失败")) {
            throw std::runtime_error("数据库收藏失败");
        }

        // 提交事务
        if (!m_db.commit()) {
            throw std::runtime_error("提交事务失败");
        }

        qDebug() << "✅" << userAccount << "收藏了视频:" << videoId;
        return true;

    } catch (const std::exception &e) {
        // 回滚事务
        m_db.rollback();
        // 回滚内存中的关系
        user->removeFavoriteVideo(videoId);
        qWarning() << "❌ 收藏视频操作失败:" << e.what();
        return false;
    }
}

// 取消收藏视频
bool DatabaseUser::removeFavoriteVideo(const QString &userAccount, const QString &videoId)
{
    User *user = getUser(userAccount);
    if (!user) {
        return false;
    }

    if (!connectToDatabase()) {
        return false;
    }

    // 开始事务
    m_db.transaction();

    try {
        // 在内存中取消收藏
        user->removeFavoriteVideo(videoId);

        // 从数据库删除收藏关系
        QSqlQuery query(m_db);
        query.prepare("DELETE FROM favorites WHERE user_account = ? AND video_id = ?");
        query.addBindValue(userAccount);
        query.addBindValue(videoId);

        if (!executeQuery(query, "删除收藏关系失败")) {
            throw std::runtime_error("数据库取消收藏失败");
        }

        // 提交事务
        if (!m_db.commit()) {
            throw std::runtime_error("提交事务失败");
        }

        qDebug() << "✅" << userAccount << "取消收藏视频:" << videoId;
        return true;

    } catch (const std::exception &e) {
        // 回滚事务
        m_db.rollback();
        // 回滚内存中的关系
        user->addFavoriteVideo(videoId);
        qWarning() << "❌ 取消收藏视频操作失败:" << e.what();
        return false;
    }
}*/

// 获取用户的收藏视频列表
QStringList DatabaseUser::getFavoriteVideos(const QString &userAccount)
{
    User *user = getUser(userAccount);
    if (user) {
        return user->getFavoriteVideos();
    }
    return QStringList();
}

bool DatabaseUser::saveToDatabase()
{
    // 保存所有用户信息到数据库
    bool success = true;
    for (User *user : m_users) {
        if (!updateUserInDatabase(user)) {
            success = false;
        }
    }
    return success;
}

//收藏
bool DatabaseUser::addFavoriteVideo(User* user, Vedio* video) {
    if (!user || !video) {
        qWarning() << "❌ 用户或视频对象为空";
        return false;
    }

    if (!connectToDatabase()) {
        return false;
    }

    // 先检查是否已经收藏
    if (user->hasCollectedVideo(video)) {
        qDebug() << "⚠️ 用户" << user->getAccount() << "已经收藏过视频:" << video->title();
        return false;
    }


    // 开始事务
    m_db.transaction();

    try {
        // 在内存中添加收藏
        if (!user->collectVideo(video)) {
            throw std::runtime_error("内存收藏失败");
        }

        // 插入收藏关系到数据库
        QSqlQuery query(m_db);
        query.prepare("INSERT INTO favorites (user_account, video_id) VALUES (?, ?)");
        query.addBindValue(user->getAccount());
        query.addBindValue(video->videoId());

        if (!executeQuery(query, "插入收藏关系失败")) {
            throw std::runtime_error("数据库收藏失败");
        }


        // 提交事务
        if (!m_db.commit()) {
            throw std::runtime_error("提交事务失败");
        }

        qDebug() << "✅" << user->getAccount() << "收藏了视频:" << video->title();
        return true;

    } catch (const std::exception &e) {
        // 回滚事务
        m_db.rollback();
        // 回滚内存中的关系
        user->uncollectVideo(video);
        qWarning() << "❌ 收藏视频操作失败:" << e.what();
        return false;
    }
}

bool DatabaseUser::removeFavoriteVideo(User* user, Vedio* video) {
    if (!user || !video) {
        qWarning() << "❌ 用户或视频对象为空";
        return false;
    }

    if (!connectToDatabase()) {
        return false;
    }

    // 开始事务
    m_db.transaction();

    try {
        // 在内存中取消收藏
        if (!user->uncollectVideo(video)) {
            throw std::runtime_error("内存取消收藏失败");
        }

        // 从数据库删除收藏关系
        QSqlQuery query(m_db);
        query.prepare("DELETE FROM favorites WHERE user_account = ? AND video_id = ?");
        query.addBindValue(user->getAccount());
        query.addBindValue(video->videoId());

        if (!executeQuery(query, "删除收藏关系失败")) {
            throw std::runtime_error("数据库取消收藏失败");
        }

        // 提交事务
        if (!m_db.commit()) {
            throw std::runtime_error("提交事务失败");
        }

        qDebug() << "✅" << user->getAccount() << "取消收藏视频:" << video->title();
        return true;

    } catch (const std::exception &e) {
        // 回滚事务
        m_db.rollback();
        // 回滚内存中的关系
        user->collectVideo(video);
        qWarning() << "❌ 取消收藏视频操作失败:" << e.what();
        return false;
    }
}

// 原有的基于字符串的方法保持不变
bool DatabaseUser::addFavoriteVideo(const QString &userAccount, const QString &videoId) {
    User *user = getUser(userAccount);
    if (!user) {
        qWarning() << "❌ 用户不存在:" << userAccount;
        return false;
    }

    // 这里需要获取视频对象，但我们没有 VideoManager 的访问权限
    // 所以这个方法的实现会受到限制
    qWarning() << "⚠️ 此方法需要 VideoManager 来获取视频对象，建议使用 addFavoriteVideo(User*, Vedio*) 方法";
    return false;
}

bool DatabaseUser::removeFavoriteVideo(const QString &userAccount, const QString &videoId) {
    User *user = getUser(userAccount);
    if (!user) {
        return false;
    }

    // 同样受到限制
    qWarning() << "⚠️ 此方法需要 VideoManager 来获取视频对象，建议使用 removeFavoriteVideo(User*, Vedio*) 方法";
    return false;
}
bool DatabaseUser::addWatchHistory(const QString &userAccount, const QString &videoUrl,const QString &videoTitle, const QString &coverUrl)
{
    if (!connectToDatabase()) {
        qWarning() << "没连接数据库.................." << userAccount;
        return false;
    }

    // 检查用户是否存在
    if (!getUser(userAccount)) {
        qWarning() << "❌ 用户不存在:" << userAccount;
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO history (user_account, video_id, video_title, video_cover, video_duration, watch_time)
        VALUES (?, ?, ?, ?, 0, 0)
    )");

    query.addBindValue(userAccount);
    query.addBindValue(videoUrl); // 将视频URL存储在video_id字段
    query.addBindValue(videoTitle);
    query.addBindValue(coverUrl);

    if (!executeQuery(query, "添加观看历史失败")) {
        return false;
    }

    qDebug() << "✅ 用户" << userAccount << "观看历史已添加:" << videoUrl;
    return true;
}
