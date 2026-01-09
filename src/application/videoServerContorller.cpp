#include "videoServerContorller.h"
#include <iostream>
#include <algorithm>

namespace application {

    domain::vo::VideoVO VideoServiceController::createVideo(const Video_Info &info)
    {

        // 调用领域层工厂
        auto video = domain::Video::createLocalVideo(info);

        domain::repository::VideoRepository rep;

        rep.addVideo(video);

        rep.saveVideoToDatabase(video);

        return convertToVO(video);
    }

    domain::vo::VideoVO VideoServiceController::addView(const std::string& videoId) {
        domain::repository::VideoRepository rep;
        auto video = rep.findById(videoId);
        if (video) {
            video->increaseViews();

            rep.saveVideoToDatabase(*video);

            return video->toVO();
        }

        return domain::vo::VideoVO{};
    }

    domain::vo::VideoVO VideoServiceController::addLike(const std::string& videoId,int count) {
        domain::repository::VideoRepository rep;
        auto video = rep.findById(videoId);
        if (video) {
            video->increaseLikes(count);
            return video->toVO();
        }
        return domain::vo::VideoVO{};
    }

    domain::vo::VideoVO VideoServiceController::addCoin(const std::string& videoId) {
        domain::repository::VideoRepository rep;
        auto video = rep.findById(videoId);
        if (video) {
            video->increaseCoins();
            return video->toVO();
        }
        return domain::vo::VideoVO{};
    }

    domain::vo::VideoVO VideoServiceController::addCollection(const std::string& videoId,int count)           {
        domain::repository::VideoRepository rep;
        auto video = rep.findById(videoId);
        if (video) {
            video->increaseCollections(count);
            return video->toVO();
        }
        return domain::vo::VideoVO{};
    }

    domain::vo::VideoVO VideoServiceController::setDownload(const std::string& videoId) {
        domain::repository::VideoRepository rep;
        auto video = rep.findById(videoId);
        if (video) {
            video->setDownloaded();
            return video->toVO();
        }
        return domain::vo::VideoVO{};
    }

    domain::vo::VideoVO VideoServiceController::addForward(const std::string& videoId) {
        domain::repository::VideoRepository rep;
        auto video = rep.findById(videoId);
        if (video) {
            video->increaseForward();
            return video->toVO();
        }
        return domain::vo::VideoVO{};
    }


    domain::vo::VideoVO VideoServiceController::getVideo(const std::string& videoId) {
        domain::repository::VideoRepository rep;
        auto video = rep.findById(videoId);

        if (!video) {
            return domain::vo::VideoVO{};
        }

        return convertToVO(*video);

    }

    std::vector<domain::vo::VideoVO> VideoServiceController::getAllVideos() {
        domain::repository::VideoRepository rep;
        return rep.findAllVideo();
    }

    domain::vo::CommentVO VideoServiceController::addComment(const std::string& videoId,
                                                             const std::string& content,
                                                             const std::string& userName)
    {
        domain::repository::VideoRepository rep;
        auto video = rep.findById(videoId);
        if (video) {
            video->addComment(content, userName);

            rep.saveVideoToDatabase(*video);

            auto comments = video->getComments();
            for (const auto& comment : comments) {
                return convertCommentToVO(comment);
            }

        }
        return domain::vo::CommentVO{};
    }

    domain::vo::CommentVO VideoServiceController::addReply(const std::string& videoId,
                                                           const std::string& parentCommentId,
                                                           const std::string& content,
                                                           const std::string& userName) {
        domain::repository::VideoRepository rep;
        auto video = rep.findById(videoId);
        if (video) {
            video->addReply(parentCommentId, content, userName);

            rep.saveVideoToDatabase(*video);

            auto parentComment = video->getCommentById(parentCommentId);
            if (!parentComment.id().empty()) {
                const auto& replies = parentComment.replies();
                for (const auto& reply : replies) {
                    return convertCommentToVO(reply);
                }
            }
        }
        return domain::vo::CommentVO{};
    }

    std::vector<domain::vo::CommentVO> VideoServiceController::getVideoComments(const std::string& videoId) {
        domain::repository::VideoRepository rep;
        auto video = rep.findById(videoId);
        std::vector<domain::vo::CommentVO> result;

        if (video) {
            auto comments = video->getComments();
            for (const auto& comment : comments) {
                result.push_back(convertCommentToVO(comment));
            }
        }

        return result;
    }

    int VideoServiceController::getVideoCommentCount(const std::string& videoId) {
        domain::repository::VideoRepository rep;
        auto video = rep.findById(videoId);
        if (video) {
            return video->getCommentCount();
        }
        return 0;
    }

    void VideoServiceController::likeComment(const std::string& videoId, const std::string& commentId) {
        domain::repository::VideoRepository rep;
        auto video = rep.findById(videoId);
        if (video) {
            video->likeComment(commentId);
        }
    }

    void VideoServiceController::unlikeComment(const std::string& videoId, const std::string& commentId) {
        domain::repository::VideoRepository rep;
        auto video = rep.findById(videoId);
        if (video) {
            video->unlikeComment(commentId);
        }
    }

    void VideoServiceController::loadVideo()
    {
        domain::repository::VideoRepository rep;
        rep.loadVideoFromDatabase();
    }

    domain::vo::VideoVO VideoServiceController::convertToVO(const domain::Video& video)
    {
        return video.toVO();
    }

    domain::vo::CommentVO VideoServiceController::convertCommentToVO(const domain::Comment& comment)
    {
        return comment.toVO();
    }

}
