#include "videoServerContorller.h"
#include <iostream>
#include <algorithm>

namespace application {

    domain::vo::VideoVO VideoServiceController::createVideo(const Video_Info &info)
    {

        // 调用领域层工厂
        auto video = domain::Video::createLocalVideo(info);

        if (video) {
            // 临时存储
            m_videos.push_back(std::make_unique<domain::Video>(*video));

            return convertToVO(*video);
        }

        return domain::vo::VideoVO{};
    }

    domain::vo::VideoVO VideoServiceController::addView(const std::string& videoId) {
        auto video = findVideoById(videoId);
        if (video) {
            video->increaseViews();
            return video->toVO();
        }
        std::cout << "无法找到id为：" << videoId << "的视频！" << std::endl;
        return domain::vo::VideoVO{};
    }

    domain::vo::VideoVO VideoServiceController::addLike(const std::string& videoId) {
        auto video = findVideoById(videoId);
        if (video) {
            video->increaseLikes();
            return video->toVO();
        }
        std::cout << "无法找到id为：" << videoId << "的视频！" << std::endl;
        return domain::vo::VideoVO{};
    }

    domain::vo::VideoVO VideoServiceController::addCoin(const std::string& videoId) {
        auto video = findVideoById(videoId);
        if (video) {
            video->increaseCoins();
            return video->toVO();
        }
        std::cout << "无法找到id为：" << videoId << "的视频！" << std::endl;
        return domain::vo::VideoVO{};
    }

    domain::vo::VideoVO VideoServiceController::addCollection(const std::string& videoId)           {
        auto video = findVideoById(videoId);
        if (video) {
            video->increaseCollections();
            return video->toVO();
        }
        std::cout << "无法找到id为：" << videoId << "的视频！" << std::endl;
        return domain::vo::VideoVO{};
    }

    domain::vo::VideoVO VideoServiceController::setDownload(const std::string& videoId) {
        auto video = findVideoById(videoId);
        if (video) {
            video->setDownloaded();
            return video->toVO();
        }
        std::cout << "无法找到id为：" << videoId << "的视频！" << std::endl;
        return domain::vo::VideoVO{};
    }

    domain::vo::VideoVO VideoServiceController::addForward(const std::string& videoId) {
        auto video = findVideoById(videoId);
        if (video) {
            video->increaseForward();
            return video->toVO();
        }
        std::cout << "无法找到id为：" << videoId << "的视频！" << std::endl;
        return domain::vo::VideoVO{};
    }


    domain::vo::VideoVO VideoServiceController::getVideo(const std::string& videoId) {
        auto video = findVideoById(videoId);

        if (!video) {
            return domain::vo::VideoVO{};
        }

        return convertToVO(*video);

    }

    std::vector<domain::vo::VideoVO> VideoServiceController::getAllVideos() {
        std::vector<domain::vo::VideoVO> result;
        for (auto& dtos : m_videos) {
            result.push_back(convertToVO(*dtos));
        }
        return result;
    }

    domain::vo::CommentVO VideoServiceController::addComment(const std::string& videoId,
                                                             const std::string& content,
                                                             const std::string& userName)
    {
        auto video = findVideoById(videoId);
        if (video) {
            video->addComment(content, userName);
            auto comments = video->getComments();
            for (const auto& comment : comments) {
                return convertCommentToVO(*comment);
            }

        }
        return domain::vo::CommentVO{};
    }

    domain::vo::CommentVO VideoServiceController::addReply(const std::string& videoId,
                                                           const std::string& parentCommentId,
                                                           const std::string& content,
                                                           const std::string& userName) {
        auto video = findVideoById(videoId);
        if (video) {
            video->addReply(parentCommentId, content, userName);
            auto parentComment = video->getCommentById(parentCommentId);
            if (parentComment) {
                const auto& replies = parentComment->replies();
                for (const auto& reply : replies) {
                    return convertCommentToVO(*reply);
                }
            }
        }
        return domain::vo::CommentVO{};
    }

    std::vector<domain::vo::CommentVO> VideoServiceController::getVideoComments(const std::string& videoId) {
        auto video = findVideoById(videoId);
        std::vector<domain::vo::CommentVO> result;

        if (video) {
            auto comments = video->getComments();
            for (const auto& comment : comments) {
                if (comment) {
                    result.push_back(convertCommentToVO(*comment));
                }
            }
        }

        return result;
    }

    int VideoServiceController::getVideoCommentCount(const std::string& videoId) {
        auto video = findVideoById(videoId);
        if (video) {
            return video->getCommentCount();
        }
        return 0;
    }

    void VideoServiceController::likeComment(const std::string& videoId, const std::string& commentId) {
        auto video = findVideoById(videoId);
        if (video) {
            video->likeComment(commentId);
        }
    }

    void VideoServiceController::unlikeComment(const std::string& videoId, const std::string& commentId) {
        auto video = findVideoById(videoId);
        if (video) {
            video->unlikeComment(commentId);
        }
    }

    // 私有辅助方法
    domain::Video* VideoServiceController::findVideoById(const std::string& id) {
        for (auto& video : m_videos) {
            if (video->id() == id) {
                return video.get();
            }
        }
        return nullptr;
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
