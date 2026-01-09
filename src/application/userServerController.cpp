#include "userServerController.h"
#include <algorithm>

namespace application {

    UserServiceController::UserServiceController(QObject* parent)
        : QObject(parent) {
        m_repository = infrastructure::UserRepository::instance();
    }

    domain::vo::UserVO UserServiceController::createUser(const domain::User::UserInfo& info) {
        if (!info.isValid()) {
            qWarning() << "❌ 用户信息无效";
            return domain::vo::UserVO{};
        }

        // 检查账号是否已存在
        if (getUserByAccount(info.account).isValid()) {
            qWarning() << "❌ 账号已存在:" << QString::fromStdString(info.account);
            return domain::vo::UserVO{};
        }

        auto user = domain::User::createLocalUser(info);
        if (!user) {
            qWarning() << "❌ 创建用户对象失败";
            return domain::vo::UserVO{};
        }

        // 保存到数据库
        if (!m_repository->saveUser(user.get())) {
            qWarning() << "❌ 保存用户到数据库失败";
            return domain::vo::UserVO{};
        }

        // 添加到内存缓存
        domain::User* userPtr = user.get();
        m_users[userPtr->id()] = std::move(user);

        // 设置在线状态
        setUserOnline(userPtr->id(), true);

        qDebug() << "✅ 用户创建成功:" << QString::fromStdString(userPtr->nickname());
        return userPtr->toVO();
    }

    domain::vo::UserVO UserServiceController::login(const std::string& account, const std::string& password) {
        // 验证登录
        if (!m_repository->validateLogin(account, password)) {
            qWarning() << "❌ 登录失败: 账号或密码错误";
            return domain::vo::UserVO{};
        }

        // 从数据库加载用户
        auto user = m_repository->getUserByAccount(account);
        if (!user) {
            qWarning() << "❌ 加载用户失败";
            return domain::vo::UserVO{};
        }

        // 设置在线状态
        if (!m_repository->setUserOnline(user->id(), true)) {
            qWarning() << "❌ 设置用户在线状态失败";
        }

        // 添加到内存缓存
        domain::User* userPtr = user.get();
        m_users[userPtr->id()] = std::move(user);
        m_onlineUsers[userPtr->id()] = true;

        qDebug() << "✅ 用户登录成功:" << QString::fromStdString(userPtr->nickname());
        return userPtr->toVO();
    }

    bool UserServiceController::logout(const std::string& userId) {
        // 设置离线状态
        bool success = m_repository->setUserOnline(userId, false);

        // 从内存缓存中移除
        auto it = m_users.find(userId);
        if (it != m_users.end()) {
            m_users.erase(it);
            m_onlineUsers.erase(userId);
            qDebug() << "✅ 用户已从内存缓存移除:" << QString::fromStdString(userId);
        }

        return success;
    }

    domain::vo::UserVO UserServiceController::updateUserProfile(const std::string& userId,
                                                               const std::string& nickname,
                                                               const std::string& signature,
                                                               const std::string& avatarUrl) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            qWarning() << "❌ 用户不存在:" << QString::fromStdString(userId);
            return domain::vo::UserVO{};
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                qWarning() << "❌ 加载用户失败";
                return domain::vo::UserVO{};
            }
        }

        userPtr->updateProfile(nickname, signature, avatarUrl);

        // 更新到数据库
        if (!m_repository->updateUser(userPtr)) {
            qWarning() << "❌ 更新用户资料到数据库失败";
            return domain::vo::UserVO{};
        }

        qDebug() << "✅ 用户资料更新成功:" << QString::fromStdString(userPtr->nickname());
        return userPtr->toVO();
    }

    domain::vo::UserVO UserServiceController::changePassword(const std::string& userId,
                                                            const std::string& newPassword) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            qWarning() << "❌ 用户不存在:" << QString::fromStdString(userId);
            return domain::vo::UserVO{};
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                qWarning() << "❌ 加载用户失败";
                return domain::vo::UserVO{};
            }
        }

        userPtr->changePassword(newPassword);

        // 更新到数据库
        if (!m_repository->updateUser(userPtr)) {
            qWarning() << "❌ 更新密码到数据库失败";
            return domain::vo::UserVO{};
        }

        qDebug() << "✅ 密码修改成功:" << QString::fromStdString(userPtr->account());
        return userPtr->toVO();
    }

    domain::vo::UserVO UserServiceController::activatePremium(const std::string& userId, int months) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            qWarning() << "❌ 用户不存在:" << QString::fromStdString(userId);
            return domain::vo::UserVO{};
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                qWarning() << "❌ 加载用户失败";
                return domain::vo::UserVO{};
            }
        }

        userPtr->activatePremium(months);

        // 更新到数据库
        if (!m_repository->updateUser(userPtr)) {
            qWarning() << "❌ 激活会员到数据库失败";
            return domain::vo::UserVO{};
        }

        qDebug() << "✅ 会员激活成功:" << QString::fromStdString(userPtr->nickname());
        return userPtr->toVO();
    }

    domain::vo::UserVO UserServiceController::cancelPremium(const std::string& userId) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            qWarning() << "❌ 用户不存在:" << QString::fromStdString(userId);
            return domain::vo::UserVO{};
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                qWarning() << "❌ 加载用户失败";
                return domain::vo::UserVO{};
            }
        }

        userPtr->cancelPremium();

        // 更新到数据库
        if (!m_repository->updateUser(userPtr)) {
            qWarning() << "❌ 取消会员到数据库失败";
            return domain::vo::UserVO{};
        }

        qDebug() << "✅ 会员取消成功:" << QString::fromStdString(userPtr->nickname());
        return userPtr->toVO();
    }

    domain::vo::UserVO UserServiceController::followUser(const std::string& followerId,
                                                        const std::string& followingId) {
        if (followerId == followingId) {
            qWarning() << "❌ 不能关注自己";
            return domain::vo::UserVO{};
        }

        auto followerVO = getUserById(followerId);
        auto followingVO = getUserById(followingId);

        if (!followerVO.isValid() || !followingVO.isValid()) {
            qWarning() << "❌ 用户不存在";
            return domain::vo::UserVO{};
        }

        // 查找内存中的用户
        domain::User* follower = findUserInMemory(followerId);
        domain::User* following = findUserInMemory(followingId);

        if (!follower) {
            follower = loadUserFromRepository(followerId);
        }
        if (!following) {
            following = loadUserFromRepository(followingId);
        }

        if (!follower || !following) {
            qWarning() << "❌ 加载用户失败";
            return domain::vo::UserVO{};
        }

        // 检查是否已经关注
        if (follower->isFollowing(followingId)) {
            qWarning() << "❌ 已经关注了该用户";
            return follower->toVO();
        }

        // 在内存中建立关注关系
        follower->follow(followingId);
        follower->increaseFollowing(1);

        // 更新被关注者的粉丝数
        following->increaseFans(1);

        // 保存关注关系到数据库
        if (!m_repository->addFollowRelation(followerId, followingId)) {
            qWarning() << "❌ 保存关注关系到数据库失败";
            // 回滚内存中的关系
            follower->unfollow(followingId);
            follower->increaseFollowing(-1);
            following->increaseFans(-1);
            return domain::vo::UserVO{};
        }

        // 更新用户信息到数据库
        m_repository->updateUser(follower);
        m_repository->updateUser(following);

        qDebug() << "✅ 关注成功:" << QString::fromStdString(follower->nickname())
                 << "关注了" << QString::fromStdString(following->nickname());
        return follower->toVO();
    }

    domain::vo::UserVO UserServiceController::unfollowUser(const std::string& followerId,
                                                          const std::string& followingId) {
        auto followerVO = getUserById(followerId);
        auto followingVO = getUserById(followingId);

        if (!followerVO.isValid() || !followingVO.isValid()) {
            qWarning() << "❌ 用户不存在";
            return domain::vo::UserVO{};
        }

        // 查找内存中的用户
        domain::User* follower = findUserInMemory(followerId);
        domain::User* following = findUserInMemory(followingId);

        if (!follower) {
            follower = loadUserFromRepository(followerId);
        }
        if (!following) {
            following = loadUserFromRepository(followingId);
        }

        if (!follower || !following) {
            qWarning() << "❌ 加载用户失败";
            return domain::vo::UserVO{};
        }

        // 检查是否已经关注
        if (!follower->isFollowing(followingId)) {
            qWarning() << "❌ 未关注该用户";
            return follower->toVO();
        }

        // 在内存中取消关注关系
        follower->unfollow(followingId);
        if (follower->followingCount() > 0) {
            follower->increaseFollowing(-1);
        }

        // 更新被关注者的粉丝数
        if (following->fansCount() > 0) {
            following->increaseFans(-1);
        }

        // 从数据库删除关注关系
        if (!m_repository->removeFollowRelation(followerId, followingId)) {
            qWarning() << "❌ 删除关注关系从数据库失败";
            // 回滚内存中的关系
            follower->follow(followingId);
            follower->increaseFollowing(1);
            following->increaseFans(1);
            return domain::vo::UserVO{};
        }

        // 更新用户信息到数据库
        m_repository->updateUser(follower);
        m_repository->updateUser(following);

        qDebug() << "✅ 取消关注成功:" << QString::fromStdString(follower->nickname())
                 << "取消关注" << QString::fromStdString(following->nickname());
        return follower->toVO();
    }

    bool UserServiceController::isFollowing(const std::string& followerId,
                                           const std::string& followingId) {
        auto follower = getUserById(followerId);
        if (!follower.isValid()) {
            return false;
        }

        // 查找内存中的用户
        domain::User* followerPtr = findUserInMemory(followerId);
        if (!followerPtr) {
            followerPtr = loadUserFromRepository(followerId);
            if (!followerPtr) {
                return false;
            }
        }

        return followerPtr->isFollowing(followingId);
    }

    domain::vo::UserVO UserServiceController::addFavoriteVideo(const std::string& userId,
                                                              const std::string& videoId) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            qWarning() << "❌ 用户不存在:" << QString::fromStdString(userId);
            return domain::vo::UserVO{};
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                qWarning() << "❌ 加载用户失败";
                return domain::vo::UserVO{};
            }
        }

        // 检查是否已经收藏
        if (userPtr->hasFavoriteVideo(videoId)) {
            qWarning() << "❌ 已经收藏了该视频";
            return userPtr->toVO();
        }

        // 在内存中添加收藏
        userPtr->addFavoriteVideo(videoId);

        // 保存收藏关系到数据库
        if (!m_repository->addFavoriteVideo(userId, videoId)) {
            qWarning() << "❌ 保存收藏关系到数据库失败";
            // 回滚内存中的关系
            userPtr->removeFavoriteVideo(videoId);
            return domain::vo::UserVO{};
        }

        qDebug() << "✅ 收藏视频成功:" << QString::fromStdString(userPtr->nickname())
                 << "收藏了视频" << QString::fromStdString(videoId);
        return userPtr->toVO();
    }

    domain::vo::UserVO UserServiceController::removeFavoriteVideo(const std::string& userId,
                                                                 const std::string& videoId) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            qWarning() << "❌ 用户不存在:" << QString::fromStdString(userId);
            return domain::vo::UserVO{};
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                qWarning() << "❌ 加载用户失败";
                return domain::vo::UserVO{};
            }
        }

        // 检查是否已经收藏
        if (!userPtr->hasFavoriteVideo(videoId)) {
            qWarning() << "❌ 未收藏该视频";
            return userPtr->toVO();
        }

        // 在内存中移除收藏
        userPtr->removeFavoriteVideo(videoId);

        // 从数据库删除收藏关系
        if (!m_repository->removeFavoriteVideo(userId, videoId)) {
            qWarning() << "❌ 删除收藏关系从数据库失败";
            // 回滚内存中的关系
            userPtr->addFavoriteVideo(videoId);
            return domain::vo::UserVO{};
        }

        qDebug() << "✅ 取消收藏成功:" << QString::fromStdString(userPtr->nickname())
                 << "取消收藏视频" << QString::fromStdString(videoId);
        return userPtr->toVO();
    }

    domain::vo::UserVO UserServiceController::addWatchHistory(const std::string& userId,
                                                             const std::string& videoId,
                                                             const std::string& videoTitle,
                                                             const std::string& coverUrl) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            qWarning() << "❌ 用户不存在:" << QString::fromStdString(userId);
            return domain::vo::UserVO{};
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                qWarning() << "❌ 加载用户失败";
                return domain::vo::UserVO{};
            }
        }

        // 在内存中添加历史记录
        userPtr->addWatchHistory(videoId);

        // 保存历史记录到数据库
        if (!m_repository->addWatchHistory(userId, videoId, videoTitle, coverUrl)) {
            qWarning() << "❌ 保存历史记录到数据库失败";
            return userPtr->toVO();
        }

        qDebug() << "✅ 添加观看历史成功:" << QString::fromStdString(userPtr->nickname())
                 << "观看了视频" << QString::fromStdString(videoId);
        return userPtr->toVO();
    }

    domain::vo::UserVO UserServiceController::clearWatchHistory(const std::string& userId) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            qWarning() << "❌ 用户不存在:" << QString::fromStdString(userId);
            return domain::vo::UserVO{};
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                qWarning() << "❌ 加载用户失败";
                return domain::vo::UserVO{};
            }
        }

        // 在内存中清空历史记录
        userPtr->clearWatchHistory();

        // 从数据库清空历史记录
        if (!m_repository->clearWatchHistory(userId)) {
            qWarning() << "❌ 清空历史记录从数据库失败";
            return userPtr->toVO();
        }

        qDebug() << "✅ 清空观看历史成功:" << QString::fromStdString(userPtr->nickname());
        return userPtr->toVO();
    }

    domain::vo::UserVO UserServiceController::addCreatedVideo(const std::string& userId,
                                                             const std::string& videoId) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            qWarning() << "❌ 用户不存在:" << QString::fromStdString(userId);
            return domain::vo::UserVO{};
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                qWarning() << "❌ 加载用户失败";
                return domain::vo::UserVO{};
            }
        }

        // 在内存中添加创建的视频
        userPtr->addCreatedVideo(videoId);
        userPtr->increaseVideoCount(1);

        // 更新用户信息到数据库
        if (!m_repository->updateUser(userPtr)) {
            qWarning() << "❌ 更新用户信息到数据库失败";
            // 回滚内存中的操作
            userPtr->increaseVideoCount(-1);
            return userPtr->toVO();
        }

        qDebug() << "✅ 添加创作视频成功:" << QString::fromStdString(userPtr->nickname())
                 << "创建了视频" << QString::fromStdString(videoId);
        return userPtr->toVO();
    }

    domain::vo::UserVO UserServiceController::getUserById(const std::string& userId) {
        // 首先在内存中查找
        domain::User* user = findUserInMemory(userId);
        if (user) {
            return user->toVO();
        }

        // 从数据库加载
        user = loadUserFromRepository(userId);
        if (user) {
            return user->toVO();
        }

        return domain::vo::UserVO{};
    }

    domain::vo::UserVO UserServiceController::getUserByAccount(const std::string& account) {
        // 首先在内存中查找
        for (const auto& pair : m_users) {
            if (pair.second->account() == account) {
                return pair.second->toVO();
            }
        }

        // 从数据库加载
        domain::User* user = loadUserByAccountFromRepository(account);
        if (user) {
            return user->toVO();
        }

        return domain::vo::UserVO{};
    }

    std::vector<domain::vo::UserVO> UserServiceController::getAllUsers() {
        std::vector<domain::vo::UserVO> userVOs;

        // 从数据库加载所有用户
        auto dbUsers = m_repository->getAllUsers();
        for (auto& user : dbUsers) {
            domain::User* userPtr = user.get();
            m_users[userPtr->id()] = std::move(user);
            userVOs.push_back(userPtr->toVO());
        }

        return userVOs;
    }

    std::vector<domain::vo::UserVO> UserServiceController::getFollowingUsers(const std::string& userId) {
        std::vector<domain::vo::UserVO> followingUsers;

        auto user = getUserById(userId);
        if (!user.isValid()) {
            return followingUsers;
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                return followingUsers;
            }
        }

        const auto& followingIds = userPtr->getFollowingIds();
        for (const auto& id : followingIds) {
            auto followingUser = getUserById(id);
            if (followingUser.isValid()) {
                followingUsers.push_back(followingUser);
            }
        }

        return followingUsers;
    }

    std::vector<domain::vo::UserVO> UserServiceController::getFollowerUsers(const std::string& userId) {
        std::vector<domain::vo::UserVO> followerUsers;

        auto user = getUserById(userId);
        if (!user.isValid()) {
            return followerUsers;
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                return followerUsers;
            }
        }

        const auto& followerIds = userPtr->getFollowerIds();
        for (const auto& id : followerIds) {
            auto followerUser = getUserById(id);
            if (followerUser.isValid()) {
                followerUsers.push_back(followerUser);
            }
        }

        return followerUsers;
    }

    std::vector<std::string> UserServiceController::getFavoriteVideos(const std::string& userId) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            return {};
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                return {};
            }
        }

        return userPtr->getFavoriteVideoIds();
    }

    std::vector<std::string> UserServiceController::getWatchHistory(const std::string& userId) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            return {};
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                return {};
            }
        }

        return userPtr->getWatchHistoryIds();
    }

    int UserServiceController::getUserCount() const {
        return m_users.size();
    }

    int UserServiceController::getOnlineUserCount() const {
        int count = 0;
        for (const auto& pair : m_onlineUsers) {
            if (pair.second) {
                count++;
            }
        }
        return count;
    }

    bool UserServiceController::setUserOnline(const std::string& userId, bool online) {
        bool success = m_repository->setUserOnline(userId, online);
        if (success) {
            m_onlineUsers[userId] = online;
            qDebug() << "✅ 用户在线状态更新:" << QString::fromStdString(userId)
                     << (online ? "在线" : "离线");
        }

        return success;
    }

    domain::User* UserServiceController::findUserInMemory(const std::string& userId) {
        auto it = m_users.find(userId);
        if (it != m_users.end()) {
            return it->second.get();
        }
        return nullptr;
    }

    domain::User* UserServiceController::loadUserFromRepository(const std::string& userId) {
        auto user = m_repository->getUserById(userId);
        if (!user) {
            return nullptr;
        }

        domain::User* userPtr = user.get();
        m_users[userId] = std::move(user);

        // 加载用户的投币记录
        auto coinRecords = m_repository->getUserVideoCoins(userId);
        for (const auto& pair : coinRecords) {
            userPtr->setVideoCoinCount(pair.first, pair.second);
        }

        return userPtr;
    }

    domain::User* UserServiceController::loadUserByAccountFromRepository(const std::string& account) {
        auto user = m_repository->getUserByAccount(account);
        if (!user) {
            return nullptr;
        }

        domain::User* userPtr = user.get();
        m_users[userPtr->id()] = std::move(user);

        // 加载用户的投币记录
        auto coinRecords = m_repository->getUserVideoCoins(userPtr->id());
        for (const auto& pair : coinRecords) {
            userPtr->setVideoCoinCount(pair.first, pair.second);
        }

        return userPtr;
    }

    void UserServiceController::updateUserStatistics(domain::User* user) {
        if (!user) {
            return;
        }

        // 更新关注数
        user->setFollowingCount(user->getFollowingIds().size());

        // 更新粉丝数
        user->setFansCount(user->getFollowerIds().size());

        // 更新视频数
        user->setVideoCount(user->getCreatedVideoIds().size());
    }

    // 点赞

    domain::vo::UserVO UserServiceController::addLikedVideo(const std::string& userId,
                                                            const std::string& videoId) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            qWarning() << "❌ 用户不存在:" << QString::fromStdString(userId);
            return domain::vo::UserVO{};
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                qWarning() << "❌ 加载用户失败";
                return domain::vo::UserVO{};
            }
        }

        // 检查是否已经点赞
        if (userPtr->hasLikedVideo(videoId)) {
            qWarning() << "❌ 已经点赞了该视频";
            return userPtr->toVO();
        }

        // 在内存中添加点赞
        userPtr->addLikedVideo(videoId);

        // 保存点赞关系到数据库
        if (!m_repository->addLikedVideo(userId, videoId)) {
            qWarning() << "❌ 保存点赞关系到数据库失败";
            // 回滚内存中的关系
            userPtr->removeLikedVideo(videoId);
            return domain::vo::UserVO{};
        }

        qDebug() << "✅ 点赞视频成功:" << QString::fromStdString(userPtr->nickname())
                 << "点赞了视频" << QString::fromStdString(videoId);
        return userPtr->toVO();
    }

    domain::vo::UserVO UserServiceController::removeLikedVideo(const std::string& userId,
                                                               const std::string& videoId) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            qWarning() << "❌ 用户不存在:" << QString::fromStdString(userId);
            return domain::vo::UserVO{};
        }

        // 查找内存中的用户
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                qWarning() << "❌ 加载用户失败";
                return domain::vo::UserVO{};
            }
        }

        // 检查是否已经点赞
        if (!userPtr->hasLikedVideo(videoId)) {
            qWarning() << "❌ 未点赞该视频";
            return userPtr->toVO();
        }

        // 在内存中移除点赞
        userPtr->removeLikedVideo(videoId);

        // 从数据库删除点赞关系
        if (!m_repository->removeLikedVideo(userId, videoId)) {
            qWarning() << "❌ 删除点赞关系从数据库失败";
            // 回滚内存中的关系
            userPtr->addLikedVideo(videoId);
            return domain::vo::UserVO{};
        }

        qDebug() << "✅ 取消点赞成功:" << QString::fromStdString(userPtr->nickname())
                 << "取消点赞视频" << QString::fromStdString(videoId);
        return userPtr->toVO();
    }

    bool UserServiceController::isVideoLiked(const std::string& userId,
                                             const std::string& videoId) {
        auto user = getUserById(userId);
        if (!user.isValid()) {
            return false;
        }

        // 首先在内存中检查
        domain::User* userPtr = findUserInMemory(userId);
        if (!userPtr) {
            userPtr = loadUserFromRepository(userId);
            if (!userPtr) {
                return false;
            }
        }

        return userPtr->hasLikedVideo(videoId);
    }

    // 投币
    bool UserServiceController::addVideoCoin(const std::string& userId,
                                             const std::string& videoId) {
        // 验证用户存在
        auto userVO = getUserById(userId);
        if (!userVO.isValid()) {
            qWarning() << "❌ 用户不存在:" << QString::fromStdString(userId);
            return false;
        }

        // 查找内存中的用户
        domain::User* user = findUserInMemory(userId);
        if (!user) {
            user = loadUserFromRepository(userId);
            if (!user) {
                qWarning() << "❌ 加载用户失败";
                return false;
            }
        }

        // 在内存中添加投币记录
        user->addVideoCoin(videoId);

        // 添加投币记录到数据库
        bool success = m_repository->addVideoCoin(userId, videoId);

        if (success) {
            qDebug() << "✅ 投币成功: 用户" << QString::fromStdString(userId)
                << "向视频" << QString::fromStdString(videoId) << "投币1个";
        } else {
            qWarning() << "❌ 投币失败: 用户" << QString::fromStdString(userId)
                << "向视频" << QString::fromStdString(videoId) << "投币失败";
        }

        return success;
    }

    int UserServiceController::getUserVideoCoinCount(const std::string& userId,
                                                     const std::string& videoId) {
        // 首先在内存中查找用户
        domain::User* user = findUserInMemory(userId);
        if (user) {
            // 从内存中的用户对象获取投币数
            return user->getVideoCoinCount(videoId);
        }

        // 如果内存中没有，从数据库加载
        user = loadUserFromRepository(userId);
        if (user) {
            // 返回从数据库加载的投币数
            return user->getVideoCoinCount(videoId);
        }

        qWarning() << "❌ 获取用户投币数失败: 用户" << QString::fromStdString(userId) << "不存在";
        return 0;
    }
}
