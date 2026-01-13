#include "userController.h"
#include <QDebug>



namespace interface {
    // 初始化静态成员变量
    UserController* UserController::m_instance = nullptr;

    UserController::UserController(QObject* parent)
        : QObject(parent) {
        // 初始化服务
    }

    UserController::~UserController() {
        qDebug() << "UserController 销毁";
    }

    UserController* UserController::instance() {
        if (!m_instance) {
            m_instance = new UserController();
        }
        return m_instance;
    }


    void UserController::destroyInstance() {
        if (m_instance) {
            delete m_instance;
            m_instance = nullptr;
        }
    }


    void UserController::registerUser(const QString& account,
                                     const QString& password,
                                     const QString& nickname,
                                     const QString& avatarUrl) {
        setLoading(true);

        domain::User::UserInfo info;
        info.account = account.toStdString();
        info.password = password.toStdString();
        info.nickname = nickname.toStdString();
        info.avatarUrl = avatarUrl.toStdString();

        domain::vo::UserVO user = m_service.createUser(info);
        if (user.isValid()) {
            setCurrentUser(user);
            emit registrationSuccess(QString::fromStdString(user.id));
            qDebug() << "✅ 用户注册成功:" << nickname;
        } else {
            emit errorOccurred("注册失败，账号可能已存在");
            qWarning() << "❌ 用户注册失败";
        }

        setLoading(false);
    }

    void UserController::login(const QString& account, const QString& password) {
        setLoading(true);

        domain::vo::UserVO user = m_service.login(account.toStdString(), password.toStdString());
        if (user.isValid()) {
            setCurrentUser(user);
            emit loginSuccess(QString::fromStdString(user.id));
            qDebug() << "✅ 用户登录成功:" << QString::fromStdString(user.nickname);
        } else {
            emit errorOccurred("登录失败，账号或密码错误");
            qWarning() << "❌ 用户登录失败";
        }

        setLoading(false);
    }

    void UserController::logout() {
        if (!isLoggedIn()) {
            return;
        }

        bool success = m_service.logout(m_currentUserId);
        if (success) {
            m_currentUserId.clear();
            m_currentUser.clear();
            emit currentUserChanged();
            emit loginStatusChanged();
            emit logoutSuccess();
            qDebug() << "✅ 用户退出登录成功";
        } else {
            emit errorOccurred("退出登录失败");
        }
    }

    void UserController::updateProfile(const QString& nickname,
                                      const QString& signature,
                                      const QString& avatarUrl) {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        domain::vo::UserVO user = m_service.updateUserProfile(
            m_currentUserId,
            nickname.toStdString(),
            signature.toStdString(),
            avatarUrl.toStdString()
        );

        if (user.isValid()) {
            updateCurrentUser(user);
            emit avatarUrlChanged();
            emit currentUserChanged();
            emit profileUpdated();
            qDebug() << "✅ 用户资料更新成功";
        } else {

            emit errorOccurred("更新资料失败");
        }

        setLoading(false);
    }

    void UserController::changePassword(const QString& newPassword) {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        domain::vo::UserVO user = m_service.changePassword(
            m_currentUserId,
            newPassword.toStdString()
        );

        if (user.isValid()) {
            updateCurrentUser(user);
            emit passwordChanged();
            qDebug() << "✅ 密码修改成功";
        } else {
            emit errorOccurred("修改密码失败");
        }

        setLoading(false);
    }

    void UserController::activatePremium(int months) {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        domain::vo::UserVO user = m_service.activatePremium(m_currentUserId, months);

        if (user.isValid()) {
            updateCurrentUser(user);
            emit premiumActivated();
            qDebug() << "✅ 会员激活成功";
        } else {
            emit errorOccurred("激活会员失败");
        }

        setLoading(false);
    }

    void UserController::cancelPremium() {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        domain::vo::UserVO user = m_service.cancelPremium(m_currentUserId);

        if (user.isValid()) {
            updateCurrentUser(user);
            emit premiumCanceled();
            qDebug() << "✅ 会员取消成功";
        } else {
            emit errorOccurred("取消会员失败");
        }

        setLoading(false);
    }

    void UserController::followUser(const QString& userId) {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        domain::vo::UserVO user = m_service.followUser(
            m_currentUserId,
            userId.toStdString()
        );

        if (user.isValid()) {
            updateCurrentUser(user);
            emit userFollowed(userId);
            qDebug() << "✅ 关注用户成功:" << userId;
        } else {
            emit errorOccurred("关注用户失败");
        }

        setLoading(false);
    }

    void UserController::unfollowUser(const QString& userId) {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        domain::vo::UserVO user = m_service.unfollowUser(
            m_currentUserId,
            userId.toStdString()
        );

        if (user.isValid()) {
            updateCurrentUser(user);
            emit userUnfollowed(userId);
            qDebug() << "✅ 取消关注用户成功:" << userId;
        } else {
            emit errorOccurred("取消关注失败");
        }

        setLoading(false);
    }

    bool UserController::isFollowing(const QString& userId) {
        if (!isLoggedIn()) {
            return false;
        }

        return m_service.isFollowing(m_currentUserId, userId.toStdString());
    }

    // void UserController::addFavoriteVideo(const QString& videoId) {
    //     if (!isLoggedIn()) {
    //         emit errorOccurred("请先登录");
    //         return;
    //     }

    //     // 获取VideoController单例实例
    //     interface::VideoController* videoController = interface::VideoController::instance();
    //     //videoController->addCollection(videoId);

    //     setLoading(true);

    //     domain::vo::UserVO user = m_service.addFavoriteVideo(
    //         m_currentUserId,
    //         videoId.toStdString()
    //     );

    //     if (user.isValid()) {
    //         updateCurrentUser(user);
    //         emit favoriteAdded(videoId);
    //         qDebug() << "✅ 收藏视频成功:" << videoId;
    //     } else {
    //         emit errorOccurred("收藏视频失败");
    //     }

    //     setLoading(false);
    // }

    QString UserController::avatarUrl() const {
        auto it = m_currentUser.find("avatarUrl");
        if (it != m_currentUser.end()) {
            return it->toString();
        }
        return "";
    }

    void UserController::addFavoriteVideo(const QString& videoId) {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        // 检查是否已经收藏
        bool alreadyFavorite = false;
        for (const auto& favoriteId : m_favoriteVideos) {
            if (favoriteId.toString() == videoId) {
                alreadyFavorite = true;
                break;
            }
        }

        if (alreadyFavorite) {
            // 已经收藏，执行取消收藏
            domain::vo::UserVO user = m_service.removeFavoriteVideo(
                m_currentUserId,
                videoId.toStdString()
                );

            if (user.isValid()) {
                updateCurrentUser(user);
                emit favoriteRemoved(videoId);

                // 更新本地收藏列表
                QVariantList newFavorites;
                for (const auto& fav : m_favoriteVideos) {
                    if (fav.toString() != videoId) {
                        newFavorites.append(fav);
                    }
                }
                m_favoriteVideos = newFavorites;
                emit favoritesChanged();

                // 通知VideoController取消收藏
                interface::VideoController* videoController = interface::VideoController::instance();
                //videoController->removeCollection(videoId);
                videoController->addCollection(videoId,-1);


                qDebug() << "✅ 取消收藏视频成功:" << videoId;
            } else {
                emit errorOccurred("取消收藏失败");
            }
        } else {
            // 尚未收藏，执行收藏
            domain::vo::UserVO user = m_service.addFavoriteVideo(
                m_currentUserId,
                videoId.toStdString()
                );

            if (user.isValid()) {
                updateCurrentUser(user);

                // 更新本地收藏列表
                m_favoriteVideos.append(videoId);
                emit favoriteAdded(videoId);
                emit favoritesChanged();

                // 通知VideoController添加收藏
                interface::VideoController* videoController = interface::VideoController::instance();
                videoController->addCollection(videoId);

                qDebug() << "✅ 收藏视频成功:" << videoId;
            } else {
                emit errorOccurred("收藏视频失败");
            }
        }

        setLoading(false);
    }

    void UserController::removeFavoriteVideo(const QString& videoId) {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        domain::vo::UserVO user = m_service.removeFavoriteVideo(
            m_currentUserId,
            videoId.toStdString()
        );

        if (user.isValid()) {
            updateCurrentUser(user);
            emit favoriteRemoved(videoId);
            removeFavoriteFromLocalList(videoId);
            emit favoritesChanged();
            qDebug() << "✅ 取消收藏视频成功:" << videoId;
        } else {
            emit errorOccurred("取消收藏失败");
        }

        setLoading(false);
    }

    // void UserController::addWatchHistory(const QString& videoId,
    //                                     const QString& videoTitle,
    //                                     const QString& coverUrl) {
    //     if (!isLoggedIn()) {
    //         return; // 历史记录可以不为登录用户记录
    //     }
    //     interface::VideoController* videoController = interface::VideoController::instance();

    //     domain::vo::UserVO user = m_service.addWatchHistory(
    //         m_currentUserId,
    //         videoId.toStdString(),
    //         videoTitle.toStdString(),
    //         coverUrl.toStdString()
    //     );

    //     if (user.isValid()) {
    //         updateCurrentUser(user);
    //         emit historyAdded(videoId);
    //         videoController->addView(videoId);
    //         qDebug() << "✅ 添加观看历史成功:" << videoId;
    //     }
    //
    // userController.cpp 中修改 addWatchHistory 方法
    void UserController::addWatchHistory(const QString& videoId,
                                         const QString& videoTitle,
                                         const QString& coverUrl) {
        if (!isLoggedIn()) {
            return; // 历史记录可以不为登录用户记录
        }

        interface::VideoController* videoController = interface::VideoController::instance();

        // 首先检查这个视频是否已经在本会话中被观看过
        bool alreadyWatched = m_watchedVideoIds.contains(videoId);

        domain::vo::UserVO user = m_service.addWatchHistory(
            m_currentUserId,
            videoId.toStdString(),
            videoTitle.toStdString(),
            coverUrl.toStdString()
            );

        if (user.isValid()) {
            updateCurrentUser(user);
            emit historyAdded(videoId);

            // 只有在之前没有观看过的情况下才增加播放量
            if (!alreadyWatched) {
                videoController->addView(videoId);
                m_watchedVideoIds.insert(videoId); // 记录这个视频已经被观看
                qDebug() << "✅ 添加观看历史成功，增加播放量:" << videoId;
            } else {
                qDebug() << "✅ 更新观看历史时间，不增加播放量:" << videoId;
            }
        }
    }

    void UserController::clearWatchHistory() {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        domain::vo::UserVO user = m_service.clearWatchHistory(m_currentUserId);

        if (user.isValid()) {
            updateCurrentUser(user);
            emit historyCleared();
            qDebug() << "✅ 清空观看历史成功";
        } else {
            emit errorOccurred("清空历史记录失败");
        }

        setLoading(false);
    }

    void UserController::addCreatedVideo(const QString& videoId) {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        domain::vo::UserVO user = m_service.addCreatedVideo(
            m_currentUserId,
            videoId.toStdString()
        );

        if (user.isValid()) {
            updateCurrentUser(user);
            qDebug() << "✅ 添加创作视频成功:" << videoId;
        }
    }

    QVariantMap UserController::getUserById(const QString& userId) {
        domain::vo::UserVO user = m_service.getUserById(userId.toStdString());
        if (user.isValid()) {
            return user.toVariantMap();
        }
        return QVariantMap();
    }

    QVariantMap UserController::getUserByAccount(const QString& account) {
        domain::vo::UserVO user = m_service.getUserByAccount(account.toStdString());
        if (user.isValid()) {
            return user.toVariantMap();
        }
        return QVariantMap();
    }

    void UserController::loadFollowingUsers() {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        auto following = m_service.getFollowingUsers(m_currentUserId);
        m_following = userVOListToVariantList(following);

        emit followingChanged();
        setLoading(false);
    }

    void UserController::loadFollowerUsers() {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        auto followers = m_service.getFollowerUsers(m_currentUserId);
        m_followers = userVOListToVariantList(followers);

        emit followersChanged();
        setLoading(false);
    }

    void UserController::loadFavoriteVideos() {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            m_favoriteVideos.clear();
            emit favoritesChanged();
            return;
        }

        setLoading(true);

        // ✅ 正确类型：std::vector<std::string>
        std::vector<std::string> favorites =
            m_service.getFavoriteVideos(m_currentUserId);

        // ✅ 正确转换
        m_favoriteVideos = stringListToVariantList(favorites);

        qDebug() << "✅ loadFavoriteVideos 收藏ID:" << m_favoriteVideos;

        emit favoritesChanged();
        setLoading(false);
    }



    void UserController::loadWatchHistory() {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        auto history = m_service.getWatchHistory(m_currentUserId);
        m_watchHistory = stringListToVariantList(history);

        emit historyChanged();
        setLoading(false);
    }

    void UserController::setLoading(bool loading) {
        if (m_loading != loading) {
            m_loading = loading;
            emit loadingChanged();
        }
    }

    void UserController::setCurrentUser(const domain::vo::UserVO& user) {
        if (!user.isValid()) {
            return;
        }

        m_currentUserId = user.id;
        m_currentUser = user.toVariantMap();

        // 初始化收藏列表
        m_favoriteVideos = m_currentUser["favoriteVideoIds"].toList();
        emit favoritesChanged();


        // 初始化点赞列表
        m_likedVideos = m_currentUser["likedVideoIds"].toList();


        // 初始化投币记录
        QVariantMap coinMap = m_currentUser["videoCoins"].toMap();
        for (auto it = coinMap.begin(); it != coinMap.end(); ++it) {
            m_userVideoCoins[it.key()] = it.value().toInt();
        }
        m_avatarTimestamp = QDateTime::currentMSecsSinceEpoch();
        emit avatarUrlChanged();

        emit currentUserChanged();
        emit loginStatusChanged();

    }

    void UserController::updateCurrentUser(const domain::vo::UserVO& user) {
        if (!user.isValid() || user.id != m_currentUserId) {
            return;
        }

        m_currentUser = user.toVariantMap();

        // 更新收藏列表
        m_favoriteVideos = m_currentUser["favoriteVideoIds"].toList();

        m_likedVideos = m_currentUser["likedVideoIds"].toList();

        // 更新投币记录
        QVariantMap coinMap = m_currentUser["videoCoins"].toMap();
        for (auto it = coinMap.begin(); it != coinMap.end(); ++it) {
            m_userVideoCoins[it.key()] = it.value().toInt();
        }

        emit currentUserChanged();
        emit favoritesChanged(); // 发出收藏列表变化信号

    }

    QVariantList UserController::userVOListToVariantList(const std::vector<domain::vo::UserVO>& users) {
        QVariantList list;
        for (const auto& user : users) {
            if (user.isValid()) {
                list.append(user.toVariantMap());
            }
        }
        return list;
    }

    QVariantList UserController::stringListToVariantList(const std::vector<std::string>& strings) {
        QVariantList list;
        for (const auto& str : strings) {
            list.append(QString::fromStdString(str));
        }
        return list;
    }

    bool UserController::isVideoFavorited(const QString& videoId) const {
        if (!isLoggedIn()) {
            return false;
        }

        for (const auto& favoriteId : m_favoriteVideos) {
            if (favoriteId.toString() == videoId) {
                return true;
            }
        }

        return false;
    }

    void UserController::removeFavoriteFromLocalList(const QString& videoId) {
        QVariantList newFavorites;
        for (const auto& fav : m_favoriteVideos) {
            if (fav.toString() != videoId) {
                newFavorites.append(fav);
            }
        }
        m_favoriteVideos = newFavorites;
    }

    //点赞

    void UserController::toggleLikeVideo(const QString& videoId) {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        // 检查是否已经点赞
        bool alreadyLiked = false;
        for (const auto& likedId : m_likedVideos) {
            if (likedId.toString() == videoId) {
                alreadyLiked = true;
                break;
            }
        }

        if (alreadyLiked) {
            // 已经点赞，执行取消点赞
            domain::vo::UserVO user = m_service.removeLikedVideo(
                m_currentUserId,
                videoId.toStdString()
                );

            if (user.isValid()) {
                updateCurrentUser(user);
                emit videoUnliked(videoId);

                // 更新本地点赞列表
                QVariantList newLikedVideos;
                for (const auto& liked : m_likedVideos) {
                    if (liked.toString() != videoId) {
                        newLikedVideos.append(liked);
                    }
                }
                m_likedVideos = newLikedVideos;

                // 通知VideoController取消点赞
                interface::VideoController* videoController = interface::VideoController::instance();
                videoController->addLike(videoId,-1);

                qDebug() << "✅ 取消点赞视频成功:" << videoId;
            } else {
                emit errorOccurred("取消点赞失败");
            }
        } else {
            // 尚未点赞，执行点赞
            domain::vo::UserVO user = m_service.addLikedVideo(
                m_currentUserId,
                videoId.toStdString()
                );

            if (user.isValid()) {
                updateCurrentUser(user);

                // 更新本地点赞列表
                m_likedVideos.append(videoId);
                emit videoLiked(videoId);

                // 通知VideoController添加点赞
                interface::VideoController* videoController = interface::VideoController::instance();
                videoController->addLike(videoId);

                qDebug() << "✅ 点赞视频成功:" << videoId;
            } else {
                emit errorOccurred("点赞视频失败");
            }
        }

        setLoading(false);
    }

    bool UserController::isVideoLiked(const QString& videoId) const {
        if (!isLoggedIn()) {
            return false;
        }

        // 首先在本地列表中查找
        for (const auto& likedId : m_likedVideos) {
            if (likedId.toString() == videoId) {
                return true;
            }
        }

        return false;
    }

    // 投币
    void UserController::addVideoCoin(const QString& videoId) {
        if (!isLoggedIn()) {
            emit errorOccurred("请先登录");
            return;
        }

        setLoading(true);

        // 调用服务层添加投币记录到数据库
        bool success = m_service.addVideoCoin(m_currentUserId, videoId.toStdString());

        if (success) {
            // 更新本地记录
            int currentCoins = m_userVideoCoins.value(videoId, 0);
            currentCoins++;
            m_userVideoCoins[videoId] = currentCoins;

            // 调用VideoController增加视频硬币数
            interface::VideoController* videoController = interface::VideoController::instance();
            videoController->addCoin(videoId);

            emit videoCoined(videoId, currentCoins);
            qDebug() << "✅ 投币成功: 视频" << videoId << "获得1个硬币，用户共投币" << currentCoins << "次";
        } else {
            emit errorOccurred("投币失败，请稍后重试");
        }

        setLoading(false);
    }

    int UserController::getUserVideoCoinCount(const QString& videoId)  {
        if (!isLoggedIn()) {
            return 0;
        }

        // 首先从本地缓存获取
        if (m_userVideoCoins.contains(videoId)) {
            return m_userVideoCoins[videoId];
        }

        // 从服务层获取（如果本地没有）
        return m_service.getUserVideoCoinCount(m_currentUserId, videoId.toStdString());
    }
}

