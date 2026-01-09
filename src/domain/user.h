#pragma once
#include <string>
#include <vector>
#include <chrono>
#include <memory>
#include <QVariantMap>
#include "userVO.h"


namespace domain {

    class User {
    public:
        struct UserInfo {
            std::string account;
            std::string password;
            std::string nickname;
            std::string avatarUrl;
            std::string signature;

            bool isValid() const {
                return !account.empty() && !password.empty() && !nickname.empty();
            }
        };

        // 工厂方法
        static std::unique_ptr<User> createLocalUser(const UserInfo& info);

        // 基本操作
        void updateProfile(const std::string& nickname,
                           const std::string& signature,
                           const std::string& avatarUrl);
        void changePassword(const std::string& newPassword);

        // 会员操作
        void activatePremium(int months = 1);
        void cancelPremium();

        // 关注关系
        void follow(const std::string& userId);
        void unfollow(const std::string& userId);
        bool isFollowing(const std::string& userId) const;
        bool isFollowedBy(const std::string& userId) const;

        // 内容操作
        void addFavoriteVideo(const std::string& videoId);
        void removeFavoriteVideo(const std::string& videoId);
        bool hasFavoriteVideo(const std::string& videoId) const;

        void addWatchHistory(const std::string& videoId);
        void clearWatchHistory();

        void addCreatedVideo(const std::string& videoId);


        void addLikedVideo(const std::string& videoId);
        void removeLikedVideo(const std::string& videoId);
        bool hasLikedVideo(const std::string& videoId) const;

        void addVideoCoin(const std::string& videoId);
        int getVideoCoinCount(const std::string& videoId) const;


        // 统计操作
        void increaseLikes(int count = 1);
        void increaseFans(int count = 1);
        void increaseFollowing(int count = 1);
        void increaseVideoCount(int count = 1);
        void increaseCoinCount(int count = 1);

        // 获取信息
        const std::string& id() const { return m_id; }
        const std::string& account() const { return m_account; }
        const std::string& password() const { return m_password; }
        const std::string& nickname() const { return m_nickname; }
        const std::string& avatarUrl() const { return m_avatarUrl; }
        const std::string& signature() const { return m_signature; }
        const std::string& level() const { return m_level; }


        int fansCount() const { return m_fansCount; }
        int followingCount() const { return m_followingCount; }
        int likesCount() const { return m_likesCount; }
        int videoCount() const { return m_videoCount; }
        int coinCount() const { return m_coinCount; }
        bool isPremiumMember() const { return m_isPremiumMember; }

        const std::vector<std::string>& getFollowingIds() const { return m_followingIds; }
        const std::vector<std::string>& getFollowerIds() const { return m_followerIds; }
        const std::vector<std::string>& getFavoriteVideoIds() const { return m_favoriteVideoIds; }
        const std::vector<std::string>& getWatchHistoryIds() const { return m_watchHistoryIds; }
        const std::vector<std::string>& getCreatedVideoIds() const { return m_createdVideos; }
        const std::vector<std::string>& getLikedVideoIds() const { return m_likedVideoIds; }

        // 转换方法
        domain::vo::UserVO toVO() const;

        // 设置方法（用于从数据库加载）
        void setId(const std::string& id) { m_id = id; }
        void setLevel(const std::string& level) { m_level = level; }
        void setFollowingCount(int count) { m_followingCount = count; }
        void setFansCount(int count) { m_fansCount = count; }
        void setLikesCount(int count) { m_likesCount = count; }
        void setVideoCount(int count) { m_videoCount = count; }
        void setCoinCount(int count) { m_coinCount = count; }
        void setPremiumMember(bool premium) { m_isPremiumMember = premium; }
        void setPremiumExpiry(const std::chrono::system_clock::time_point& expiry) {
            m_premiumExpiryDate = expiry;
        }
        void setVideoCoinCount(const std::string& videoId, int count) {
            m_videoCoins[videoId] = count;
        }

        void addFollowerId(const std::string& userId) { m_followerIds.push_back(userId); }

    private:
        User() = default;

        std::string m_id;
        std::string m_account;
        std::string m_password;
        std::string m_nickname;
        std::string m_avatarUrl;
        std::string m_signature;
        std::string m_level = "1";

        int m_followingCount = 0;
        int m_fansCount = 0;
        int m_likesCount = 0;
        int m_videoCount = 0;
        int m_coinCount = 0;

        bool m_isPremiumMember = false;
        std::chrono::system_clock::time_point m_premiumExpiryDate;

        std::vector<std::string> m_followingIds;
        std::vector<std::string> m_followerIds;
        std::vector<std::string> m_favoriteVideoIds;
        std::vector<std::string> m_watchHistoryIds;
        std::vector<std::string> m_createdVideos;
        std::vector<std::string> m_likedVideoIds;
        std::map<std::string, int> m_videoCoins;  // 用户对每个视频的投币数

        void validate();

        // 静态成员函数声明
        static std::string generateUniqueId();
        static std::string getCurrentTimeString();
    };
}
