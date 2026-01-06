#include <iostream>
#include <memory>
#include <unordered_map>
#include "videoVO.h"
#include "comment.h"

namespace domain {

    class Video
    {
    public:
        struct Video_Info
        {
            std::string title;
            std::string author;
            std::string description;
            std::string uploadDate;

            std::string videoUrl;
            std::string coverUrl;
            std::string headUrl;

            bool isValid() const { return !title.empty() && !author.empty() && !videoUrl.empty(); }

        };


        domain::vo::VideoVO toVO() const
        {
            domain::vo::VideoVO vo =
            {
                .id = m_id,
                .title = m_title,
                .author = m_author,
                .description = m_description,
                .uploadDate = m_uploadDate,
                .videoUrl = m_videoUrl,
                .coverUrl = m_coverUrl,
                .headUrl = m_headUrl,
                .viewCount = m_viewCount,
                .likeCount = m_likeCount,
                .coinCount = m_coinCount,
                .collectionCount = m_collectionCount,
                .downloaded = m_downloaded,
                .forwardCount = m_forwardCount,

                .bulletCount = m_bulletCount,
                .followerCount = m_followerCount,

                .commitCount = m_commitCount,
            };

            auto comments = getComments();
            for (const auto& comment : comments) {
                if (comment) { vo.comments.push_back(comment->toVO()); }
            }

            return vo;
        }

        static std::unique_ptr<Video> createLocalVideo(const Video_Info &info); //创建本地视频

        void increaseViews(int count = 1);
        void increaseLikes(int count = 1);
        void increaseCoins(int count = 1);
        void increaseCollections(int count = 1);
        void setDownloaded();
        void increaseForward(int const = 1);
        const std::string &id() const{return m_id;}

        //评论内容
        void addComment(const std::string& content, const std::string& userName);
        void addReply(const std::string& parentCommentId,
                      const std::string& content,
                      const std::string& userName);
        Comment *getCommentById(const std::string &commentId) ;
        std::vector<const Comment*> getComments() const;

        int getCommentCount() const { return m_commitCount;}

        void likeComment(const std::string& commentId);
        void unlikeComment(const std::string& commentId);

    private:

        Video() = default;

        std::string m_id = "";                //视频唯一id
        std::string m_title = "空标题";             //标题
        std::string m_author = "空名字";            //up主名字
        std::string m_description ="这个人很懒，什么描述都没有";       //描述
        std::string m_uploadDate;      //上传时间
        int m_viewCount = 0;         //播放量
        int m_likeCount = 0;         //点赞数
        int m_coinCount = 0;         //硬币数量
        int m_collectionCount = 0;   //收藏数量
        bool m_downloaded = false;   //缓存
        int m_forwardCount = 0;      //转发数量

        int m_bulletCount = 0;       //弹幕数量
        int m_followerCount = 0;     //粉丝数

        int m_commitCount = 0;       //评论数量

        std::string m_videoUrl; //视频url
        std::string m_coverUrl; //封面url
        std::string m_headUrl;  //头像url

        std::unordered_map<std::string,std::shared_ptr<Comment>> commentMap;

        void validate(); //检测创建视频的时候属性是否正常
        // Comment* findCommentById(const std::string& commentId);

    };

}


