#pragma once
#include <string>
#include <vector>
#include <chrono>
#include <QVariantMap>
#include <QVariantList>
#include <QDateTime>
#include <iomanip>
#include <sstream>

namespace domain::vo {

    struct CommentVO {

        std::string id;
        std::string userName;
        std::chrono::system_clock::time_point time;
        std::string content;

        int likeCount = 0;
        int unlikeCount = 0;

        bool isReply = false;
        std::string parentId;

        std::vector<CommentVO> replies;

        bool isValid() const {
            return !id.empty() && !userName.empty() && !content.empty();
        }

        // 转换到 QVariantMap（用于 QML）
        QVariantMap toVariantMap() const {
            QVariantList repliesList;
            for (const auto& reply : replies) {
                repliesList.append(reply.toVariantMap());
            }

            return {
                    {"id", QString::fromStdString(id)},
                    {"userName", QString::fromStdString(userName)},
                    {"time", QString::fromStdString(timeToString())},
                    {"formattedTime", formattedTime()},
                    {"content", QString::fromStdString(content)},
                    {"likeCount", likeCount},
                    {"unlikeCount", unlikeCount},
                    {"isReply", isReply},
                    {"parentId", QString::fromStdString(parentId)},
                    {"replies", repliesList},
                    };
        }

    private:

        // 转换时间到字符串
        std::string timeToString() const {
            auto t = std::chrono::system_clock::to_time_t(time);
            std::stringstream ss;
            ss << std::put_time(std::localtime(&t), "%Y-%m-%d %H:%M:%S");
            return ss.str();
        }

        // 格式化时间（用于显示）
        QString formattedTime() const {
            auto t = std::chrono::system_clock::to_time_t(time);
            QDateTime dateTime = QDateTime::fromSecsSinceEpoch(t);
            QDateTime now = QDateTime::currentDateTime();
            qint64 seconds = dateTime.secsTo(now);

            if (seconds < 60) {
                return QString("刚刚");
            } else if (seconds < 3600) {
                return QString("%1分钟前").arg(seconds / 60);
            } else if (seconds < 86400) {
                return QString("%1小时前").arg(seconds / 3600);
            } else if (seconds < 2592000) { // 30天
                return QString("%1天前").arg(seconds / 86400);
            } else {
                return dateTime.toString("yyyy-MM-dd");
            }
        }

    };

}
