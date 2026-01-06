#pragma once
#include <string>
#include <QVariantMap>
#include"commentVO.h"

namespace domain::vo {

    struct VideoVO {
        // 核心标识字段
        std::string id;
        std::string title;
        std::string author;
        std::string description;
        std::string uploadDate;
        std::string videoUrl;
        std::string coverUrl;
        std::string headUrl;

        // 统计字
        int viewCount = 0;
        int likeCount = 0;
        int coinCount = 0;
        int collectionCount = 0;
        bool downloaded = false;
        int forwardCount = 0;
        int bulletCount = 0;
        int followerCount = 0;
        int commitCount = 0;

        std::vector<CommentVO> comments;


        QVariantMap toVariantMap() const {
            return {
                {"id", QString::fromStdString(id)},
                {"title", QString::fromStdString(title)},
                {"author", QString::fromStdString(author)},
                {"description", QString::fromStdString(description)},
                {"uploadDate", QString::fromStdString(uploadDate)},
                {"viewCount", viewCount},
                {"likeCount", likeCount},
                {"coinCount", coinCount},
                {"collectionCount", collectionCount},
                {"downloaded",downloaded},
                {"forwardCount",forwardCount},
                {"bulletCount",bulletCount},
                {"followerCount",followerCount},
                {"commitCount",commitCount},
                {"videoUrl", QString::fromStdString(videoUrl)},
                {"coverUrl", QString::fromStdString(coverUrl)},
                {"headUrl", QString::fromStdString(headUrl)},


                // 计算字段
                {"formattedViewCount", formatViewCount(viewCount)},
                {"formattedLikeCount", formatCount(likeCount)},
                {"popularityBadge", getPopularityBadge()}
            };
        }

        bool isValid() const {
            return !id.empty() && !title.empty() && !author.empty();
        }

    private:

        static QString formatViewCount(int count) {
            if (count >= 10000) {
                return QString("%1万").arg(count / 10000.0, 0, 'f', 1);
            }
            return QString::number(count);
        }

        static QString formatCount(int count) {
            if (count >= 1000) {
                return QString("%1K").arg(count / 1000.0, 0, 'f', 1);
            }
            return QString::number(count);
        }

        QString getPopularityBadge() const {
            if (viewCount > 10000) return "🔥 热门";
            if (viewCount > 1000) return "⭐ 优质";
            return "📺 普通";
        }
    };

}
