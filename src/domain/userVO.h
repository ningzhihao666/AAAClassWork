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

    struct UserVO {
        // 用户基本信息
        std::string id;
        std::string account;
        std::string password;
        std::string nickname;
        std::string avatarUrl;
        std::string signature;
        std::string level;

        // 统计信息
        int followingCount = 0;
        int fansCount = 0;
        int likesCount = 0;
        int videoCount = 0;
        int coinCount = 0;

        // 会员状态
        bool isPremiumMember = false;
        std::chrono::system_clock::time_point premiumExpiryDate;

        // 关系
        std::vector<std::string> followingIds;
        std::vector<std::string> followerIds;

        // 内容
        std::vector<std::string> favoriteVideoIds;
        std::vector<std::string> watchHistoryIds;
        std::vector<std::string> createdVideoIds;
        std::vector<std::string> likedVideoIds;
        std::map<std::string, int> videoCoins;

        QVariantMap toVariantMap() const {

            QVariantMap coinMap;
            for (const auto& pair : videoCoins) {
                coinMap[QString::fromStdString(pair.first)] = pair.second;
            }

            QVariantList likedList;
            for (const auto& videoId : likedVideoIds) {
                likedList.append(QString::fromStdString(videoId));
            }

            QVariantList favoriteList;
            for (const auto& videoId : favoriteVideoIds) {
                favoriteList.append(QString::fromStdString(videoId));
            }

            QVariantList historyList;
            for (const auto& historyId : watchHistoryIds) {
                historyList.append(QString::fromStdString(historyId));
            }

            QVariantList followingList;
            for (const auto& userId : followingIds) {
                followingList.append(QString::fromStdString(userId));
            }

            QVariantList followerList;
            for (const auto& userId : followerIds) {
                followerList.append(QString::fromStdString(userId));
            }

            QVariantList createdList;
            for (const auto& videoId : createdVideoIds) {
                createdList.append(QString::fromStdString(videoId));
            }

            auto formatCount = [](int count) -> QString {
                if (count >= 10000) {
                    return QString("%1万").arg(count / 10000.0, 0, 'f', 1);
                } else if (count >= 1000) {
                    return QString("%1K").arg(count / 1000.0, 0, 'f', 1);
                }
                return QString::number(count);
            };

            QString premiumStatus = "非会员";
            if (isPremiumMember) {
                auto now = std::chrono::system_clock::now();
                auto remaining = std::chrono::duration_cast<std::chrono::hours>(
                                     premiumExpiryDate - now).count() / 24;

                if (remaining > 0) {
                    premiumStatus = QString("大会员剩余%1天").arg(remaining);
                } else {
                    premiumStatus = "大会员已过期";
                }
            }

            return {
                {"videoCoins", coinMap},
                {"likedVideoIds", likedList},
                {"id", QString::fromStdString(id)},
                {"account", QString::fromStdString(account)},
                {"password", QString::fromStdString(password)},
                {"nickname", QString::fromStdString(nickname)},
                {"avatarUrl", QString::fromStdString(avatarUrl)},
                {"signature", QString::fromStdString(signature)},
                {"level", QString::fromStdString(level)},
                {"followingCount", followingCount},
                {"fansCount", fansCount},
                {"likesCount", likesCount},
                {"videoCount", videoCount},
                {"coinCount", coinCount},
                {"isPremiumMember", isPremiumMember},
                {"followingIds", followingList},
                {"followerIds", followerList},
                {"favoriteVideoIds", favoriteList},
                {"watchHistoryIds", historyList},
                {"createdVideoIds", createdList},
                {"formattedFollowingCount", formatCount(followingCount)},
                {"formattedFansCount", formatCount(fansCount)},
                {"formattedLikesCount", formatCount(likesCount)},
                {"premiumStatus", premiumStatus}
            };
        }

        bool isValid() const {
            return !id.empty() && !account.empty() && !nickname.empty();
        }
    };
}
