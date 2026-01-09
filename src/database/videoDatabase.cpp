// videoDatabase.cpp
#include "videoDatabase.h"
#include <stdexcept>
#include <QDebug>
#include <QVariant>

namespace database {
    VideoDatabase* VideoDatabase::instance = nullptr;

    VideoDatabase& VideoDatabase::getInstance()
    {
        if (!instance) {
            instance = new VideoDatabase();
        }
        return *instance;
    }

    bool VideoDatabase::connectToDatabase(const std::string& host,
                                          int port,
                                          const std::string& database,
                                          const std::string& user,
                                          const std::string& password,
                                          const std::string& connectionName)
    {
        std::cout << "VideoDatabase: 尝试连接数据库..." << std::endl;
        std::cout << "  主机: " << host << std::endl;
        std::cout << "  端口: " << port << std::endl;
        std::cout << "  数据库: " << database << std::endl;
        std::cout << "  用户: " << user << std::endl;

        m_connectionName = connectionName;

        if (m_db.isOpen()) {
            std::cout << "关闭现有数据库连接..." << std::endl;
            m_db.close();
        }

        m_db = QSqlDatabase::addDatabase("QMYSQL", QString::fromStdString(connectionName));
        m_db.setHostName(QString::fromStdString(host));
        m_db.setPort(port);
        m_db.setDatabaseName(QString::fromStdString(database));
        m_db.setUserName(QString::fromStdString(user));
        m_db.setPassword(QString::fromStdString(password));

        m_db.setConnectOptions("MYSQL_OPT_CONNECT_TIMEOUT=15;MYSQL_OPT_READ_TIMEOUT=15;MYSQL_OPT_WRITE_TIMEOUT=15");

        std::cout << "正在连接数据库..." << std::endl;
        bool success = m_db.open();

        if (!success) {
            QSqlError error = m_db.lastError();
            std::cout << "❌ VideoDatabase: 数据库连接失败" << std::endl;
            std::cout << "错误类型: " << error.type() << std::endl;
            std::cout << "错误信息: " << error.text().toStdString() << std::endl;
            std::cout << "数据库错误: " << error.databaseText().toStdString() << std::endl;
            std::cout << "驱动错误: " << error.driverText().toStdString() << std::endl;
            m_isConnected = false;
        } else {
            std::cout << "✅ VideoDatabase: 数据库连接成功" << std::endl;
            std::cout << "数据库连接名称: " << m_db.connectionName().toStdString() << std::endl;
            std::cout << "数据库驱动名称: " << m_db.driverName().toStdString() << std::endl;
            m_isConnected = true;

            // 连接成功后创建表
            bool videoTableCreated = createVideoTable();
            bool commentTableCreated = createCommentTable();

            if (!videoTableCreated) {
                std::cout << "❌ 创建视频表失败" << std::endl;
                m_isConnected = false;
                m_db.close();
            } else if (!commentTableCreated) {
                std::cout << "❌ 创建评论表失败" << std::endl;
                m_isConnected = false;
                m_db.close();
            } else {
                std::cout << "✅ 视频表和评论表创建成功" << std::endl;
            }
        }

        return m_isConnected;
    }

    bool VideoDatabase::createVideoTable()
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接，无法创建表" << std::endl;
            return false;
        }

        QSqlQuery query(m_db);

        QString sql = R"(
            CREATE TABLE IF NOT EXISTS videos (
                id VARCHAR(255) PRIMARY KEY,
                title VARCHAR(500) NOT NULL,
                author VARCHAR(255) NOT NULL,
                description TEXT,
                upload_date VARCHAR(50),
                view_count INT DEFAULT 0,
                like_count INT DEFAULT 0,
                coin_count INT DEFAULT 0,
                collection_count INT DEFAULT 0,
                downloaded BOOLEAN DEFAULT FALSE,
                forward_count INT DEFAULT 0,
                bullet_count INT DEFAULT 0,
                follower_count INT DEFAULT 0,
                commit_count INT DEFAULT 0,
                video_url TEXT NOT NULL,
                cover_url TEXT,
                head_url TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        )";

        if (!query.exec(sql)) {
            QSqlError error = query.lastError();
            std::cout << "创建视频表失败: " << error.text().toStdString() << std::endl;
            return false;
        }

        return true;
    }

    bool VideoDatabase::createCommentTable()
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接，无法创建表" << std::endl;
            return false;
        }

        QSqlQuery query(m_db);

        QString sql = R"(
            CREATE TABLE IF NOT EXISTS comments (
                id VARCHAR(255) PRIMARY KEY,
                video_id VARCHAR(255) NOT NULL,
                user_name VARCHAR(255) NOT NULL,
                content TEXT NOT NULL,
                comment_time VARCHAR(50) NOT NULL,
                like_count INT DEFAULT 0,
                unlike_count INT DEFAULT 0,
                is_reply BOOLEAN DEFAULT FALSE,
                parent_id VARCHAR(255),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_video_id (video_id),
                INDEX idx_parent_id (parent_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        )";

        if (!query.exec(sql)) {
            QSqlError error = query.lastError();
            std::cout << "创建评论表失败: " << error.text().toStdString() << std::endl;
            return false;
        }

        std::cout << "✅ 评论表创建成功" << std::endl;
        return true;
    }

    bool VideoDatabase::videoExists(const std::string& videoId)
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("SELECT COUNT(*) FROM videos WHERE id = ?");
        query.addBindValue(QString::fromStdString(videoId));

        if (!query.exec()) {
            QSqlError error = query.lastError();
            std::cout << "检查视频是否存在失败: " << error.text().toStdString() << std::endl;
            return false;
        }

        if (query.next()) {
            return query.value(0).toInt() > 0;
        }

        return false;
    }

    bool VideoDatabase::saveVideoVOToDatabase(const domain::vo::VideoVO& vo)
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return false;
        }

        if (!vo.isValid()) {
            std::cout << "VideoVO数据无效" << std::endl;
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare(R"(
            INSERT INTO videos (id, title, author, description, upload_date,
                               view_count, like_count, coin_count, collection_count,
                               downloaded, forward_count, bullet_count, follower_count,
                               commit_count, video_url, cover_url, head_url)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        )");

        query.addBindValue(QString::fromStdString(vo.id));
        query.addBindValue(QString::fromStdString(vo.title));
        query.addBindValue(QString::fromStdString(vo.author));
        query.addBindValue(QString::fromStdString(vo.description));
        query.addBindValue(QString::fromStdString(vo.uploadDate));
        query.addBindValue(vo.viewCount);
        query.addBindValue(vo.likeCount);
        query.addBindValue(vo.coinCount);
        query.addBindValue(vo.collectionCount);
        query.addBindValue(vo.downloaded);
        query.addBindValue(vo.forwardCount);
        query.addBindValue(vo.bulletCount);
        query.addBindValue(vo.followerCount);
        query.addBindValue(vo.commitCount);
        query.addBindValue(QString::fromStdString(vo.videoUrl));
        query.addBindValue(QString::fromStdString(vo.coverUrl));
        query.addBindValue(QString::fromStdString(vo.headUrl));

        if (!query.exec()) {
            QSqlError error = query.lastError();
            std::cout << "插入视频失败: " << error.text().toStdString() << std::endl;
            return false;
        }

        std::cout << "✅ 视频插入成功: " << vo.id << std::endl;
        return true;
    }

    bool VideoDatabase::updateVideoVOInDatabase(const domain::vo::VideoVO& vo)
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return false;
        }

        if (!vo.isValid()) {
            std::cout << "VideoVO数据无效" << std::endl;
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare(R"(
            UPDATE videos SET
                title = ?,
                author = ?,
                description = ?,
                upload_date = ?,
                view_count = ?,
                like_count = ?,
                coin_count = ?,
                collection_count = ?,
                downloaded = ?,
                forward_count = ?,
                bullet_count = ?,
                follower_count = ?,
                commit_count = ?,
                video_url = ?,
                cover_url = ?,
                head_url = ?
            WHERE id = ?
        )");

        query.addBindValue(QString::fromStdString(vo.title));
        query.addBindValue(QString::fromStdString(vo.author));
        query.addBindValue(QString::fromStdString(vo.description));
        query.addBindValue(QString::fromStdString(vo.uploadDate));
        query.addBindValue(vo.viewCount);
        query.addBindValue(vo.likeCount);
        query.addBindValue(vo.coinCount);
        query.addBindValue(vo.collectionCount);
        query.addBindValue(vo.downloaded);
        query.addBindValue(vo.forwardCount);
        query.addBindValue(vo.bulletCount);
        query.addBindValue(vo.followerCount);
        query.addBindValue(vo.commitCount);
        query.addBindValue(QString::fromStdString(vo.videoUrl));
        query.addBindValue(QString::fromStdString(vo.coverUrl));
        query.addBindValue(QString::fromStdString(vo.headUrl));
        query.addBindValue(QString::fromStdString(vo.id));

        if (!query.exec()) {
            QSqlError error = query.lastError();
            std::cout << "更新视频失败: " << error.text().toStdString() << std::endl;
            return false;
        }

        std::cout << "✅ 视频更新成功: " << vo.id << std::endl;
        return true;
    }

    bool VideoDatabase::saveVideoVO(const domain::vo::VideoVO& vo)
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return false;
        }

        if (!vo.isValid()) {
            std::cout << "VideoVO数据无效" << std::endl;
            return false;
        }

        // 检查视频是否存在
        if (videoExists(vo.id)) {
            return updateVideoVOInDatabase(vo);
        } else {
            return saveVideoVOToDatabase(vo);
        }
    }

    bool VideoDatabase::saveVideoToDatabase(const domain::Video& video)
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return false;
        }

        // 通过toVO()方法获取数据
        domain::vo::VideoVO vo = video.toVO();

        // 调用saveVideoVO方法保存
        return saveVideoVO(vo);
    }

    void VideoDatabase::addVideo(std::unique_ptr<domain::Video> video)
    {
        if (video) {
            std::string id = video->id();
            m_videos.emplace(id, std::move(video));
        }
    }

    domain::Video* VideoDatabase::findById(const std::string &videoId)
    {
        // 首先在本地缓存中查找
        auto it = m_videos.find(videoId);
        if (it != m_videos.end()) {
            return it->second.get();
        }

        // 如果在本地缓存中找不到，尝试从数据库加载
        std::cout << "⚠️ 本地缓存中找不到视频，尝试从数据库加载: " << videoId << std::endl;

        if (loadVideoFromDatabase(videoId)) {
            // 重新查找
            auto newIt = m_videos.find(videoId);
            if (newIt != m_videos.end()) {
                std::cout << "✅ 从数据库加载视频成功: " << videoId << std::endl;
                return newIt->second.get();
            }
        }

        std::cout << "❌ 无法找到id为：" << videoId << "的视频！" << std::endl;
        return nullptr;
    }

    std::vector<std::unique_ptr<domain::Video>> VideoDatabase::findAllVideo()
    {
        std::vector<std::unique_ptr<domain::Video>> result;
        result.reserve(m_videos.size());

        for (auto &it : m_videos) {
            result.push_back(std::make_unique<domain::Video>(*(it.second)));
        }

        return result;
    }

    std::string timePointToString(const std::chrono::system_clock::time_point& tp)
    {
        auto t = std::chrono::system_clock::to_time_t(tp);
        std::stringstream ss;
        ss << std::put_time(std::localtime(&t), "%Y-%m-%d %H:%M:%S");
        return ss.str();
    }

    bool VideoDatabase::saveCommentToDatabase(const std::string& videoId,
                                              const domain::Comment& comment,
                                              const std::string& parentId)
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return false;
        }

        // 通过toVO()获取评论数据
        domain::vo::CommentVO vo = comment.toVO();

        QSqlQuery query(m_db);
        query.prepare(R"(
            INSERT INTO comments (id, video_id, user_name, content, comment_time,
                                 like_count, unlike_count, is_reply, parent_id)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        )");

        query.addBindValue(QString::fromStdString(vo.id));
        query.addBindValue(QString::fromStdString(videoId));
        query.addBindValue(QString::fromStdString(vo.userName));
        query.addBindValue(QString::fromStdString(vo.content));
        query.addBindValue(QString::fromStdString(timePointToString(vo.time)));
        query.addBindValue(vo.likeCount);
        query.addBindValue(vo.unlikeCount);
        query.addBindValue(vo.isReply);
        query.addBindValue(parentId.empty() ? QVariant() : QString::fromStdString(parentId));

        if (!query.exec()) {
            QSqlError error = query.lastError();
            std::cout << "插入评论失败: " << error.text().toStdString() << std::endl;
            return false;
        }

        std::cout << "✅ 评论插入成功: " << vo.id << std::endl;
        return true;
    }

    bool VideoDatabase::saveCommentTree(const std::string& videoId, const domain::Comment& comment)
    {
        // 通过toVO()获取评论数据
        domain::vo::CommentVO vo = comment.toVO();

        // 保存当前评论
        std::string parentId = vo.isReply ? vo.parentId : "";  // 从VO中获取parentId
        if (!saveCommentToDatabase(videoId, comment, parentId)) {
            return false;
        }

        // 递归保存回复
        for (const auto& reply : comment.replies()) {
            if (!saveCommentTree(videoId, reply)) {
                return false;
            }
        }

        return true;
    }

    bool VideoDatabase::deleteAllCommentsForVideo(const std::string& videoId)
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return false;
        }

        QSqlQuery query(m_db);
        query.prepare("DELETE FROM comments WHERE video_id = ?");
        query.addBindValue(QString::fromStdString(videoId));

        if (!query.exec()) {
            QSqlError error = query.lastError();
            std::cout << "删除评论失败: " << error.text().toStdString() << std::endl;
            return false;
        }

        std::cout << "✅ 已删除视频 " << videoId << " 的所有旧评论" << std::endl;
        return true;
    }


    bool VideoDatabase::saveVideoWithComments(const domain::Video& video)
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return false;
        }

        std::string videoId = video.id();
        std::cout << "【调试】开始保存视频和评论: " << videoId << std::endl;

        // 1. 保存视频基本信息
        if (!saveVideoToDatabase(video)) {
            std::cout << "❌ 保存视频基本信息失败" << std::endl;
            return false;
        }
        std::cout << "✅ 视频基本信息保存成功" << std::endl;

        // 2. 删除该视频的所有旧评论
        if (!deleteAllCommentsForVideo(videoId)) {
            std::cout << "⚠️ 删除旧评论失败，但继续保存" << std::endl;
        }

        // 3. 获取视频的所有评论
        auto comments = video.getComments();
        std::cout << "【调试】获取到 " << comments.size() << " 条主评论" << std::endl;

        if (comments.empty()) {
            std::cout << "⚠️ 视频没有评论" << std::endl;
            return true;
        }

        // 4. 保存所有评论
        int savedCount = 0;
        for (const auto& comment : comments) {
            std::cout << "保存评论: " << comment.id() << std::endl;
            if (!saveCommentTree(videoId, comment)) {
                std::cout << "❌ 保存评论失败: " << comment.id() << std::endl;
                return false;
            }
            savedCount++;
        }

        std::cout << "✅ 视频和评论保存成功: " << videoId
                  << " (保存了 " << savedCount << " 条主评论及其回复)" << std::endl;
        return true;
    }

    bool VideoDatabase::saveComments(const std::string& videoId,
                                     const std::vector<domain::Comment>& comments)
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return false;
        }

        // 先删除该视频的所有评论（可选，取决于需求）
        QSqlQuery deleteQuery(m_db);
        deleteQuery.prepare("DELETE FROM comments WHERE video_id = ?");
        deleteQuery.addBindValue(QString::fromStdString(videoId));

        if (!deleteQuery.exec()) {
            std::cout << "删除旧评论失败" << std::endl;
            // 可以选择继续，不返回失败
        }

        // 保存新评论
        for (const auto& comment : comments) {
            if (!saveCommentTree(videoId, comment)) {
                std::cout << "保存评论失败: " << comment.id() << std::endl;
                return false;
            }
        }

        std::cout << "✅ 保存了 " << comments.size() << " 条评论" << std::endl;
        return true;
    }

    bool VideoDatabase::saveSingleComment(const std::string& videoId,
                                          const domain::Comment& comment)
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return false;
        }

        return saveCommentTree(videoId, comment);
    }



    // 从数据库加载视频VO
    domain::vo::VideoVO VideoDatabase::loadVideoVOFromDatabase(const std::string& videoId)
    {
        domain::vo::VideoVO vo;

        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return vo;
        }

        QSqlQuery query(m_db);
        query.prepare(R"(
        SELECT id, title, author, description, upload_date,
               view_count, like_count, coin_count, collection_count,
               downloaded, forward_count, bullet_count, follower_count,
               commit_count, video_url, cover_url, head_url
        FROM videos WHERE id = ?
    )");
        query.addBindValue(QString::fromStdString(videoId));

        if (!query.exec()) {
            QSqlError error = query.lastError();
            std::cout << "查询视频失败: " << error.text().toStdString() << std::endl;
            return vo;
        }

        if (query.next()) {
            vo.id = query.value("id").toString().toStdString();
            vo.title = query.value("title").toString().toStdString();
            vo.author = query.value("author").toString().toStdString();
            vo.description = query.value("description").toString().toStdString();
            vo.uploadDate = query.value("upload_date").toString().toStdString();
            vo.viewCount = query.value("view_count").toInt();
            vo.likeCount = query.value("like_count").toInt();
            vo.coinCount = query.value("coin_count").toInt();
            vo.collectionCount = query.value("collection_count").toInt();
            vo.downloaded = query.value("downloaded").toBool();
            vo.forwardCount = query.value("forward_count").toInt();
            vo.bulletCount = query.value("bullet_count").toInt();
            vo.followerCount = query.value("follower_count").toInt();
            vo.commitCount = query.value("commit_count").toInt();
            vo.videoUrl = query.value("video_url").toString().toStdString();
            vo.coverUrl = query.value("cover_url").toString().toStdString();
            vo.headUrl = query.value("head_url").toString().toStdString();

            std::cout << "✅ 从数据库加载视频VO: " << vo.id << std::endl;
        } else {
            std::cout << "❌ 视频不存在: " << videoId << std::endl;
        }

        return vo;
    }

    // 从数据库加载视频的所有评论
    std::vector<domain::vo::CommentVO> VideoDatabase::loadCommentsForVideo(const std::string& videoId)
    {
        std::vector<domain::vo::CommentVO> comments;

        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return comments;
        }

        QSqlQuery query(m_db);
        query.prepare(R"(
        SELECT id, video_id, user_name, content, comment_time,
               like_count, unlike_count, is_reply, parent_id
        FROM comments
        WHERE video_id = ?
        ORDER BY created_at
    )");
        query.addBindValue(QString::fromStdString(videoId));

        if (!query.exec()) {
            QSqlError error = query.lastError();
            std::cout << "查询评论失败: " << error.text().toStdString() << std::endl;
            return comments;
        }

        int count = 0;
        while (query.next()) {
            domain::vo::CommentVO vo;
            vo.id = query.value("id").toString().toStdString();
            vo.userName = query.value("user_name").toString().toStdString();
            vo.content = query.value("content").toString().toStdString();

            // 转换时间字符串为time_point
            std::string timeStr = query.value("comment_time").toString().toStdString();
            if (!timeStr.empty()) {
                try {
                    std::tm tm = {};
                    std::stringstream ss(timeStr);
                    ss >> std::get_time(&tm, "%Y-%m-%d %H:%M:%S");
                    if (!ss.fail()) {
                        auto timeT = std::mktime(&tm);
                        vo.time = std::chrono::system_clock::from_time_t(timeT);
                    }
                } catch (...) {
                    vo.time = std::chrono::system_clock::now();
                }
            }

            vo.likeCount = query.value("like_count").toInt();
            vo.unlikeCount = query.value("unlike_count").toInt();
            vo.isReply = query.value("is_reply").toBool();
            vo.parentId = query.value("parent_id").toString().toStdString();

            comments.push_back(vo);
            count++;
        }

        std::cout << "✅ 从数据库加载了 " << count << " 条评论" << std::endl;
        return comments;
    }

    // 加载评论并添加到视频中
    void VideoDatabase::loadAndAddCommentsToVideo(domain::Video* video, const std::vector<domain::vo::CommentVO>& comments)
    {
        if (!video) return;

        // 清除旧的评论
        video->clearComments();

        // 存储评论映射
        std::unordered_map<std::string, domain::vo::CommentVO> commentMap;
        for (const auto& comment : comments) {
            commentMap[comment.id] = comment;
        }

        // 先添加主评论
        for (const auto& comment : comments) {
            if (!comment.isReply) {
                // 使用数据库中的评论ID
                video->addCommentWithId(comment.content, comment.userName, comment.id);
            }
        }

        // 然后添加回复
        for (const auto& comment : comments) {
            if (comment.isReply && !comment.parentId.empty()) {
                // 使用数据库中的评论ID
                video->addReplyWithId(comment.parentId, comment.content, comment.userName, comment.id);
            }
        }
    }

    // 从数据库获取视频VO
    domain::vo::VideoVO VideoDatabase::getVideoVOFromDatabase(const std::string& videoId)
    {
        domain::vo::VideoVO vo = loadVideoVOFromDatabase(videoId);

        if (vo.isValid()) {
            // 加载评论
            vo.comments = loadCommentsForVideo(videoId);
        }

        return vo;
    }

    // 获取所有视频的VO
    std::vector<domain::vo::VideoVO> VideoDatabase::getAllVideoVOsFromDatabase()
    {
        std::vector<domain::vo::VideoVO> videoVOs;

        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return videoVOs;
        }

        QSqlQuery query(m_db);
        QString sql = R"(
        SELECT id, title, author, description, upload_date,
               view_count, like_count, coin_count, collection_count,
               downloaded, forward_count, bullet_count, follower_count,
               commit_count, video_url, cover_url, head_url
        FROM videos
    )";

        if (!query.exec(sql)) {
            QSqlError error = query.lastError();
            std::cout << "查询所有视频失败: " << error.text().toStdString() << std::endl;
            return videoVOs;
        }

        int count = 0;
        while (query.next()) {
            domain::vo::VideoVO vo;
            vo.id = query.value("id").toString().toStdString();
            vo.title = query.value("title").toString().toStdString();
            vo.author = query.value("author").toString().toStdString();
            vo.description = query.value("description").toString().toStdString();
            vo.uploadDate = query.value("upload_date").toString().toStdString();
            vo.viewCount = query.value("view_count").toInt();
            vo.likeCount = query.value("like_count").toInt();
            vo.coinCount = query.value("coin_count").toInt();
            vo.collectionCount = query.value("collection_count").toInt();
            vo.downloaded = query.value("downloaded").toBool();
            vo.forwardCount = query.value("forward_count").toInt();
            vo.bulletCount = query.value("bullet_count").toInt();
            vo.followerCount = query.value("follower_count").toInt();
            vo.commitCount = query.value("commit_count").toInt();
            vo.videoUrl = query.value("video_url").toString().toStdString();
            vo.coverUrl = query.value("cover_url").toString().toStdString();
            vo.headUrl = query.value("head_url").toString().toStdString();

            // 加载评论
            vo.comments = loadCommentsForVideo(vo.id);

            videoVOs.push_back(vo);
            count++;
        }

        std::cout << "✅ 获取了 " << count << " 个视频的VO" << std::endl;
        return videoVOs;
    }

    // 获取视频ID列表
    std::vector<std::string> VideoDatabase::getAllVideoIdsFromDatabase()
    {
        std::vector<std::string> videoIds;

        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return videoIds;
        }

        QSqlQuery query(m_db);
        QString sql = "SELECT id FROM videos";

        if (!query.exec(sql)) {
            QSqlError error = query.lastError();
            std::cout << "查询视频ID列表失败: " << error.text().toStdString() << std::endl;
            return videoIds;
        }

        while (query.next()) {
            videoIds.push_back(query.value("id").toString().toStdString());
        }

        std::cout << "✅ 获取了 " << videoIds.size() << " 个视频ID" << std::endl;
        return videoIds;
    }

    // 从数据库加载特定视频
    bool VideoDatabase::loadVideoFromDatabase(const std::string& videoId)
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return false;
        }

        std::cout << "【调试】开始加载视频: " << videoId << std::endl;

        auto it = m_videos.find(videoId);
        if (it != m_videos.end()) {
            std::cout << "⚠️ 视频已在缓存中，跳过重复加载: " << videoId << std::endl;
            return true;
        }

        // 1. 加载视频VO
        domain::vo::VideoVO vo = loadVideoVOFromDatabase(videoId);
        if (!vo.isValid()) {
            std::cout << "❌ 视频VO无效: " << videoId << std::endl;
            return false;
        }

        // 2. 创建视频对象，使用数据库ID
        domain::Video::Video_Info info = {
            .title = vo.title,
            .author = vo.author,
            .description = vo.description,
            .uploadDate = vo.uploadDate,
            .videoUrl = vo.videoUrl,
            .coverUrl = vo.coverUrl,
            .headUrl = vo.headUrl
        };

        auto video = std::make_unique<domain::Video>(domain::Video::createLocalVideo(info, videoId));

        // 3. 设置统计数据
        video->setStatistics(
            vo.viewCount, vo.likeCount, vo.coinCount,
            vo.collectionCount, vo.downloaded, vo.forwardCount,
            vo.bulletCount, vo.followerCount, vo.commitCount
            );

        // 4. 加载评论
        std::vector<domain::vo::CommentVO> comments = loadCommentsForVideo(videoId);
        if (!comments.empty()) {
            loadAndAddCommentsToVideo(video.get(), comments);
        }

        // 5. 添加到缓存
        m_videos[videoId] = std::move(video);

        std::cout << "✅ 视频加载成功: " << videoId << std::endl;
        return true;
    }

    // 从数据库加载所有视频
    bool VideoDatabase::loadAllVideosFromDatabase()
    {
        if (!m_isConnected) {
            std::cout << "数据库未连接" << std::endl;
            return false;
        }

        std::cout << "【调试】开始从数据库加载所有视频..." << std::endl;

        std::vector<std::string> videoIds = getAllVideoIdsFromDatabase();
        if (videoIds.empty()) {
            std::cout << "❌ 数据库中没有视频" << std::endl;
            return false;
        }

        int loaded = 0;
        int failed = 0;
        for (const auto& videoId : videoIds) {
            std::cout << "加载视频: " << videoId << std::endl;

            if (loadVideoFromDatabase(videoId)) {
                loaded++;
            } else {
                failed++;
            }
        }

        std::cout << "✅ 从数据库加载完成: "
                  << loaded << " 个视频成功, "
                  << failed << " 个视频失败" << std::endl;
        return loaded > 0;
    }
}
