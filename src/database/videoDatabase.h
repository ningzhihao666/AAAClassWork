#pragma once
#include <unordered_map>
#include <vector>
#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include "../domain/video.h"

namespace database {

    class VideoDatabase
    {
    private:
        static VideoDatabase* instance;
        std::unordered_map<std::string, std::unique_ptr<domain::Video>> m_videos;

        VideoDatabase() = default;
        VideoDatabase(const VideoDatabase&) = delete;
        VideoDatabase& operator=(const VideoDatabase&) = delete;

        //数据库操作
        QSqlDatabase m_db;
        bool m_isConnected = false;
        std::string m_connectionName;

        bool createVideoTable();
        bool createCommentTable();

        //辅助方法
        bool saveVideoVOToDatabase(const domain::vo::VideoVO& vo);
        bool updateVideoVOInDatabase(const domain::vo::VideoVO& vo);
        bool saveCommentToDatabase(const std::string& videoId, const domain::Comment& comment,
                                   const std::string& parentId = "");
        bool saveCommentTree(const std::string& videoId, const domain::Comment& comment);
        bool deleteAllCommentsForVideo(const std::string& videoId);

        // 加载方法
        domain::vo::VideoVO loadVideoVOFromDatabase(const std::string& videoId);
        std::vector<domain::vo::CommentVO> loadCommentsForVideo(const std::string& videoId);
        void loadAndAddCommentsToVideo(domain::Video* video, const std::vector<domain::vo::CommentVO>& comments);


    public:
        static VideoDatabase& getInstance();

        void addVideo(std::unique_ptr<domain::Video> video);

        domain::Video* findById(const std::string& videoId);

        std::vector<std::unique_ptr<domain::Video>> findAllVideo();

        //数据库
        bool connectToDatabase(const std::string& host
                               = "cq-cdb-n6tlcxx5.sql.tencentcdb.com",
                               int port = 20450,
                               const std::string& database = "video",
                               const std::string& user = "root",
                               const std::string& password = "12345678lzh",
                               const std::string& connectionName = "video_database_connection");
        bool isConnected() const { return m_isConnected; }

        // 保存Video对象到数据库
        bool saveVideoToDatabase(const domain::Video& video);

        // 保存VideoVO到数据库
        bool saveVideoVO(const domain::vo::VideoVO& vo);

        // 检查视频是否存在
        bool videoExists(const std::string& videoId);

        // 保存评论
        bool saveVideoWithComments(const domain::Video& video);
        bool saveComments(const std::string& videoId, const std::vector<domain::Comment>& comments);
        bool saveSingleComment(const std::string& videoId, const domain::Comment& comment);

        bool loadAllVideosFromDatabase(bool clearCache = true, int count = 5);

        // 加载特定视频
        bool loadVideoFromDatabase(const std::string& videoId);

        // 从数据库中获取视频VO
        domain::vo::VideoVO getVideoVOFromDatabase(const std::string& videoId);

        // 获取所有视频的VO
        std::vector<domain::vo::VideoVO> getAllVideoVOsFromDatabase();

        // 获取视频ID列表
        std::vector<std::string> getAllVideoIdsFromDatabase();

        // 清空本地缓存
        void clearLocalCache() { m_videos.clear(); }

    };

}
