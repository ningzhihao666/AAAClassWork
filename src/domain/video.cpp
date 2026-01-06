#include "video.h"
#include <iostream>
#include <chrono>
#include <random>
#include <sstream>
#include <iomanip>

namespace domain {

    namespace {
        std::string generateUniqueId()
        {
            // 使用时间戳+随机数生成唯一ID
            auto now = std::chrono::system_clock::now();
            auto timestamp = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count();

            static std::random_device rd;
            static std::mt19937 gen(rd());
            static std::uniform_int_distribution<> dis(1000, 9999);

            int random = dis(gen);

            return "video_" + std::to_string(timestamp) + "_" + std::to_string(random);
        }

        std::string getCurrentTimeString()
        {
            auto now = std::chrono::system_clock::now();
            auto in_time_t = std::chrono::system_clock::to_time_t(now);

            // 线程安全的时间格式化
            char buffer[80];
            std::strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", std::localtime(&in_time_t));

            return std::string(buffer);
        }

        bool isValidUrl(const std::string &url)
        {
            // 简单的URL验证
            return !url.empty()
                   && (url.find("http://") == 0 || url.find("https://") == 0 || url.find("file://") == 0
                       || url.find("/") == 0); // 也支持本地路径
        }
    }

    std::unique_ptr<Video> Video::createLocalVideo(const Video_Info &info)
    {
        if (!info.isValid()) {
            std::cerr << "Video创建失败：参数无效" << std::endl;
            return nullptr;
        }

        if (!isValidUrl(info.videoUrl)) {
            std::cerr << "Video创建失败：视频URL格式无效" << std::endl;
            return nullptr;
        }

        auto video = std::unique_ptr<Video>(new Video());

        video->m_id = generateUniqueId();
        video->m_title = info.title;
        video->m_author = info.author;
        video->m_description = info.description;
        video->m_videoUrl = info.videoUrl;
        video->m_uploadDate = getCurrentTimeString();
        video->m_coverUrl = info.coverUrl;
        video->m_headUrl = info.headUrl;

        std::cout << "Video创建成功，ID: " << video->m_id << std::endl;

        return video;
    }

    void Video::validate()
    {
        if (m_title.empty()) { std::cout << "视频标题不能为空！" << std::endl; }

        if (m_author.empty()) { std::cout << "视频作者不能为空" << std::endl; }

        if (!isValidUrl(m_videoUrl)) { std::cout << "视频URL格式无效" << std::endl; }
    }

    void Video::increaseViews(int count)
    {
        if (count < 0) {
            std::cerr << "错误，播放数量必须为正!" << std::endl;
            return;
        }

        m_viewCount += count;
        std::cout << "视频 " << m_id << " 播放量增加 " << count
                  << "，当前播放量: " << m_viewCount << std::endl;

    }

    void Video::increaseLikes(int count) {
        if (count <= 0) {
            std::cerr << "警告：增加点赞数必须为正数" << std::endl;
            return;
        }

        m_likeCount += count;
        std::cout << "视频 " << m_id << " 点赞数增加 " << count
                  << "，当前点赞数: " << m_likeCount << std::endl;
    }

    void Video::increaseCoins(int count) {
        if (count <= 0) {
            std::cerr << "警告：增加硬币数必须为正数" << std::endl;
            return;
        }

        m_coinCount += count;
        std::cout << "视频 " << m_id << " 硬币数增加 " << count
                  << "，当前硬币数: " << m_coinCount << std::endl;
    }

    void Video::increaseCollections(int count) {
        if (count <= 0) {
            std::cerr << "警告：增加收藏数必须为正数" << std::endl;
            return;
        }

        m_collectionCount += count;
        std::cout << "视频 " << m_id << " 收藏数增加 " << count
                  << "，当前收藏数: " << m_collectionCount << std::endl;
    }

    void Video::setDownloaded()
    {
        if (m_downloaded) {
            std::cout << "该视频已经缓存" << std::endl;
            return;
        }

        m_downloaded = true;

        std::cout << "视频进行缓存操作" << std::endl;
    }

    void Video::increaseForward(int count) {
        if (count <= 0) {
            std::cerr << "警告：转发数必须为正数" << std::endl;
            return;
        }

        m_forwardCount += count;
        std::cout << "视频 " << m_id << " 转发数增加 " << count
                  << "，当前转发数: " << m_forwardCount << std::endl;
    }

    void Video::addComment(const std::string &content, const std::string &userName)
    {
        auto comment = Comment::createRootComment(content, userName);
        if (comment) {
            std::string id = comment->id();
            commentMap[id] = std::move(comment);
            m_commitCount++;
        }
    }

    void Video::addReply(const std::string &parentCommentId, const std::string &content, const std::string &userName)
    {
        auto reply = Comment::createReplyComment(content, userName, parentCommentId);
        if (reply) {
            auto it = commentMap.find(parentCommentId);
            if (it != commentMap.end()) {
                it->second->addReply(std::move(reply));
                m_commitCount++;
            } else {
                std::cerr << "无法找到父评论！" << std::endl;
            }
        }
    }

    void Video::likeComment(const std::string &commentId)
    {
        auto comment = getCommentById(commentId);
        if (comment) { comment->addLike(); }
    }

    void Video::unlikeComment(const std::string &commentId)
    {
        auto comment = getCommentById(commentId);
        if (comment) {
            comment->addUnlike();
        }
    }

    std::vector<const Comment *> Video::getComments() const
    {
        std::vector<const Comment *> comments;
        for (const auto &pair : commentMap) {
            if (!pair.second->isReply()) { comments.push_back(pair.second.get()); }
        }
        return comments;
    }

    Comment *Video::getCommentById(const std::string &commentId)
    {
        auto it = commentMap.find(commentId);
        if (it != commentMap.end()) { return it->second.get(); }
        return nullptr;
    }

}

