#pragma once
#include <memory>
#include <string>
#include <vector>
#include "../domain/videoVO.h"
#include "../domain/videorepository.h"

namespace application {

    using Video_Info = domain::Video::Video_Info; //使用领域层结构体

    class VideoServiceController
    {
    public:
        VideoServiceController() = default;

        domain::vo::VideoVO createVideo(const Video_Info &info);

        domain::vo::VideoVO addView(const std::string& videoId);
        domain::vo::VideoVO addLike(const std::string& videoId,int count = 1);
        domain::vo::VideoVO addCoin(const std::string& videoId);
        domain::vo::VideoVO addCollection(const std::string& videoId,int count = 1);
        domain::vo::VideoVO setDownload(const std::string& videoId);
        domain::vo::VideoVO addForward(const std::string& videoId);

        // 查询
        domain::vo::VideoVO getVideo(const std::string& videoId);
        std::vector<domain::vo::VideoVO> getAllVideos();


        domain::vo::CommentVO addComment(const std::string& videoId,
                                         const std::string& content,
                                         const std::string& userName);

        domain::vo::CommentVO addReply(const std::string& videoId,
                                       const std::string& parentCommentId,
                                       const std::string& content,
                                       const std::string& userName);
        std::vector<domain::vo::CommentVO> getVideoComments(const std::string& videoId);
        int getVideoCommentCount(const std::string& videoId);

        void likeComment(const std::string& videoId, const std::string& commentId);
        void unlikeComment(const std::string& videoId, const std::string& commentId);

        void loadVideo();

        void loadMoreVideos(int count);

    private:
        domain::vo::VideoVO convertToVO(const domain::Video& video);
        domain::vo::CommentVO convertCommentToVO(const domain::Comment& comment);
    };

}
