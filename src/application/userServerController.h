#pragma once
#include <memory>
#include <string>
#include <vector>
#include <unordered_map>
#include <QObject>
#include <QDebug>
#include "../domain/user.h"
#include "../domain/userVO.h"
#include "../database/userdatabase.h"

namespace application {

    class UserServiceController : public QObject {
        Q_OBJECT

    public:
        explicit UserServiceController(QObject* parent = nullptr);

        // 用户管理
        domain::vo::UserVO createUser(const domain::User::UserInfo& info);
        domain::vo::UserVO login(const std::string& account, const std::string& password);
        bool logout(const std::string& userId);

        // 用户操作
        domain::vo::UserVO updateUserProfile(const std::string& userId,
                                             const std::string& nickname,
                                             const std::string& signature,
                                             const std::string& avatarUrl);
        domain::vo::UserVO changePassword(const std::string& userId,
                                          const std::string& newPassword);

        // 会员操作
        domain::vo::UserVO activatePremium(const std::string& userId, int months = 1);
        domain::vo::UserVO cancelPremium(const std::string& userId);

        // 关注关系
        domain::vo::UserVO followUser(const std::string& followerId,
                                      const std::string& followingId);
        domain::vo::UserVO unfollowUser(const std::string& followerId,
                                        const std::string& followingId);
        bool isFollowing(const std::string& followerId,
                         const std::string& followingId);

        // 内容操作
        domain::vo::UserVO addFavoriteVideo(const std::string& userId,
                                            const std::string& videoId);
        domain::vo::UserVO removeFavoriteVideo(const std::string& userId,
                                               const std::string& videoId);
        domain::vo::UserVO addWatchHistory(const std::string& userId,
                                           const std::string& videoId,
                                           const std::string& videoTitle = "",
                                           const std::string& coverUrl = "");
        domain::vo::UserVO clearWatchHistory(const std::string& userId);
        domain::vo::UserVO addCreatedVideo(const std::string& userId,
                                           const std::string& videoId);


        domain::vo::UserVO addLikedVideo(const std::string& userId,
                                         const std::string& videoId);
        domain::vo::UserVO removeLikedVideo(const std::string& userId,
                                            const std::string& videoId);
        bool isVideoLiked(const std::string& userId,
                          const std::string& videoId);

        bool addVideoCoin(const std::string& userId,
                          const std::string& videoId);
        int getUserVideoCoinCount(const std::string& userId,
                                  const std::string& videoId);

        // 查询
        domain::vo::UserVO getUserById(const std::string& userId);
        domain::vo::UserVO getUserByAccount(const std::string& account);
        std::vector<domain::vo::UserVO> getAllUsers();
        std::vector<domain::vo::UserVO> getFollowingUsers(const std::string& userId);
        std::vector<domain::vo::UserVO> getFollowerUsers(const std::string& userId);
        std::vector<std::string> getFavoriteVideos(const std::string& userId);
        std::vector<std::string> getWatchHistory(const std::string& userId);

        // 统计
        int getUserCount() const;
        int getOnlineUserCount() const;

        // 设置在线状态
        bool setUserOnline(const std::string& userId, bool online);

    private:
        infrastructure::UserRepository* m_repository;

        // 内存缓存
        std::unordered_map<std::string, std::unique_ptr<domain::User>> m_users;
        std::unordered_map<std::string, bool> m_onlineUsers;

        // 用户查找
        domain::User* findUserInMemory(const std::string& userId);
        domain::User* loadUserFromRepository(const std::string& userId);
        domain::User* loadUserByAccountFromRepository(const std::string& account);

        // 更新统计
        void updateUserStatistics(domain::User* user);
    };
}
