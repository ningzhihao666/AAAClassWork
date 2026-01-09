#include "videorepository.h"

namespace domain::repository {

    VideoRepository::VideoRepository()
        : db(database::VideoDatabase::getInstance())
    {
    }

    void VideoRepository::addVideo(const domain::Video& video)
    {
       auto videoCopy = std::make_unique<domain::Video>(video);
       db.addVideo(std::move(videoCopy));
    }

    domain::Video* VideoRepository::findById(const std::string& videoId)
    {
        return db.findById(videoId);
    }

    std::vector<domain::vo::VideoVO> VideoRepository::findAllVideo()
    {
        auto videoPtrs = db.findAllVideo();

        std::vector<domain::vo::VideoVO> result;
        result.reserve(videoPtrs.size());

        for (auto& videoPtr : videoPtrs) {
            if (videoPtr) {
                result.push_back(videoPtr->toVO());
            }
        }

        std::cout << "VideoRepository: 获取所有视频，数量: " << result.size() << std::endl;

        return result;
    }

    void VideoRepository::saveVideoToDatabase(const domain::Video& video)
    {
        db.saveVideoWithComments(video);
    }

    void VideoRepository::loadVideoFromDatabase()
    {
        db.loadAllVideosFromDatabase();
    }

}


