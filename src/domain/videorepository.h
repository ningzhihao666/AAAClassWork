#pragma once
#include <memory>
#include <string>
#include <vector>
#include "../database/videoDatabase.h"

namespace domain::repository {

    class VideoRepository
    {
    public:
        VideoRepository();

        void addVideo(const domain::Video& video);

        domain::Video* findById(const std::string& videoId);

        std::vector<domain::vo::VideoVO> findAllVideo();

        void saveVideoToDatabase(const domain::Video& video);

        void loadVideoFromDatabase();

        bool loadMoreVideos(int count);
        std::optional<Video> getVideoById(const std::string& videoId);


    private:
        database::VideoDatabase& db;

    };


}

