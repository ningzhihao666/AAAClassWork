#include "user.h"
#include <random>
#include <chrono>
#include <sstream>
#include <iomanip>
#include <algorithm>
#include <QDateTime>

namespace domain {

    // 静态成员函数实现
    std::string User::generateUniqueId() {
        // 使用时间戳+随机数生成唯一ID
        auto now = std::chrono::system_clock::now();
        auto timestamp = std::chrono::duration_cast<std::chrono::milliseconds>(
                             now.time_since_epoch()).count();

        static std::random_device rd;
        static std::mt19937 gen(rd());
        static std::uniform_int_distribution<> dis(1000, 9999);

        int random = dis(gen);

        return "user_" + std::to_string(timestamp) + "_" + std::to_string(random);
    }

    std::string User::getCurrentTimeString() {
        auto now = std::chrono::system_clock::now();
        auto in_time_t = std::chrono::system_clock::to_time_t(now);

        char buffer[80];
        std::strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", std::localtime(&in_time_t));

        return std::string(buffer);
    }

    std::unique_ptr<User> User::createLocalUser(const UserInfo& info) {
        if (!info.isValid()) {
            return nullptr;
        }

        auto user = std::unique_ptr<User>(new User());

        user->m_id = generateUniqueId();
        user->m_account = info.account;
        user->m_password = info.password;
        user->m_nickname = info.nickname;
        user->m_avatarUrl = info.avatarUrl;
        user->m_signature = info.signature;

        user->validate();

        return user;
    }

    void User::validate() {
        if (m_nickname.empty()) {
            m_nickname = "用户" + m_account.substr(0, 4);
        }

        if (m_avatarUrl.empty()) {
            m_avatarUrl = "https://i0.hdslb.com/bfs/face/member/noface.jpg@40w_40h.webp";
        }

        if (m_signature.empty()) {
            m_signature = "这个人很懒，什么都没有写";
        }
    }

    void User::updateProfile(const std::string& nickname,
                             const std::string& signature,
                             const std::string& avatarUrl) {
        if (!nickname.empty()) {
            m_nickname = nickname;
        }

        if (!signature.empty()) {
            m_signature = signature;
        }

        if (!avatarUrl.empty()) {
            m_avatarUrl = avatarUrl;
        }
    }

    void User::changePassword(const std::string& newPassword) {
        if (!newPassword.empty()) {
            m_password = newPassword;
        }
    }

    void User::activatePremium(int months) {
        m_isPremiumMember = true;
        auto now = std::chrono::system_clock::now();
        m_premiumExpiryDate = now + std::chrono::hours(24 * 30 * months);
    }

    void User::cancelPremium() {
        m_isPremiumMember = false;
    }

    void User::follow(const std::string& userId) {
        if (userId.empty() || userId == m_id) {
            return;
        }

        // 检查是否已经关注
        for (const auto& id : m_followingIds) {
            if (id == userId) {
                return;
            }
        }

        m_followingIds.push_back(userId);
    }

    void User::unfollow(const std::string& userId) {
        if (userId.empty()) {
            return;
        }

        auto it = std::find(m_followingIds.begin(), m_followingIds.end(), userId);
        if (it != m_followingIds.end()) {
            m_followingIds.erase(it);
        }
    }

    bool User::isFollowing(const std::string& userId) const {
        if (userId.empty()) {
            return false;
        }

        return std::find(m_followingIds.begin(), m_followingIds.end(), userId) != m_followingIds.end();
    }

    bool User::isFollowedBy(const std::string& userId) const {
        if (userId.empty()) {
            return false;
        }

        return std::find(m_followerIds.begin(), m_followerIds.end(), userId) != m_followerIds.end();
    }

    void User::addFavoriteVideo(const std::string& videoId) {
        if (videoId.empty()) {
            return;
        }

        // 检查是否已经收藏
        for (const auto& id : m_favoriteVideoIds) {
            if (id == videoId) {
                return;
            }
        }

        m_favoriteVideoIds.push_back(videoId);

    }

    void User::removeFavoriteVideo(const std::string& videoId) {
        if (videoId.empty()) {
            return;
        }

        auto it = std::find(m_favoriteVideoIds.begin(), m_favoriteVideoIds.end(), videoId);
        if (it != m_favoriteVideoIds.end()) {
            m_favoriteVideoIds.erase(it);
        }
    }

    bool User::hasFavoriteVideo(const std::string& videoId) const {
        if (videoId.empty()) {
            return false;
        }

        return std::find(m_favoriteVideoIds.begin(), m_favoriteVideoIds.end(), videoId) != m_favoriteVideoIds.end();
    }

    void User::addWatchHistory(const std::string& videoId) {
        if (videoId.empty()) {
            return;
        }

        // 如果已经存在，先移除再添加到开头
        auto it = std::find(m_watchHistoryIds.begin(), m_watchHistoryIds.end(), videoId);
        if (it != m_watchHistoryIds.end()) {
            m_watchHistoryIds.erase(it);
        }

        m_watchHistoryIds.insert(m_watchHistoryIds.begin(), videoId);

        // 限制历史记录数量
        if (m_watchHistoryIds.size() > 100) {
            m_watchHistoryIds.resize(100);
        }
    }

    void User::clearWatchHistory() {
        m_watchHistoryIds.clear();
    }

    void User::addCreatedVideo(const std::string& videoId) {
        if (videoId.empty()) {
            return;
        }

        // 检查是否已经存在
        for (const auto& id : m_createdVideos) {
            if (id == videoId) {
                return;
            }
        }

        m_createdVideos.push_back(videoId);
    }

    void User::increaseLikes(int count) {
        if (count > 0) {
            m_likesCount += count;
        }
    }

    void User::increaseFans(int count) {
        if (count > 0) {
            m_fansCount += count;
        }
    }

    void User::increaseFollowing(int count) {
        if (count > 0) {
            m_followingCount += count;
        }
    }

    void User::increaseVideoCount(int count) {
        if (count > 0) {
            m_videoCount += count;
        }
    }

    void User::increaseCoinCount(int count) {
        if (count > 0) {
            m_coinCount += count;
        }
    }

    vo::UserVO User::toVO() const {
        vo::UserVO vo;

        vo.id = m_id;
        vo.account = m_account;
        vo.password = m_password;
        vo.nickname = m_nickname;
        vo.avatarUrl = m_avatarUrl;
        vo.signature = m_signature;
        vo.level = m_level;

        vo.followingCount = m_followingCount;
        vo.fansCount = m_fansCount;
        vo.likesCount = m_likesCount;
        vo.videoCount = m_videoCount;
        vo.coinCount = m_coinCount;

        vo.isPremiumMember = m_isPremiumMember;
        vo.premiumExpiryDate = m_premiumExpiryDate;

        vo.followingIds = m_followingIds;
        vo.followerIds = m_followerIds;
        vo.favoriteVideoIds = m_favoriteVideoIds;
        vo.watchHistoryIds = m_watchHistoryIds;
        vo.createdVideoIds = m_createdVideos;
        vo.likedVideoIds = m_likedVideoIds;

        for (const auto& pair : m_videoCoins) {
            vo.videoCoins[pair.first] = pair.second;
        }

        return vo;
    }

    //点赞

    void User::addLikedVideo(const std::string& videoId) {
        if (videoId.empty()) {
            return;
        }

        // 检查是否已经点赞
        for (const auto& id : m_likedVideoIds) {
            if (id == videoId) {
                return;
            }
        }

        m_likedVideoIds.push_back(videoId);
    }

    void User::removeLikedVideo(const std::string& videoId) {
        if (videoId.empty()) {
            return;
        }

        auto it = std::find(m_likedVideoIds.begin(), m_likedVideoIds.end(), videoId);
        if (it != m_likedVideoIds.end()) {
            m_likedVideoIds.erase(it);
        }
    }

    bool User::hasLikedVideo(const std::string& videoId) const {
        if (videoId.empty()) {
            return false;
        }

        return std::find(m_likedVideoIds.begin(), m_likedVideoIds.end(), videoId) != m_likedVideoIds.end();
    }

    // 投币
    void User::addVideoCoin(const std::string& videoId) {
        if (videoId.empty()) {
            return;
        }

        // 增加用户对该视频的投币数
        m_videoCoins[videoId] = m_videoCoins[videoId] + 1;
    }

    int User::getVideoCoinCount(const std::string& videoId) const {
        if (videoId.empty()) {
            return 0;
        }

        auto it = m_videoCoins.find(videoId);
        if (it != m_videoCoins.end()) {
            return it->second;
        }

        return 0;
    }
}
