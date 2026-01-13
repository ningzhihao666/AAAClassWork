#pragma once
#include <QObject>
#include <QVariant>
#include "../application/userServerController.h"
#include "../presentation/videoController.h"

namespace interface {

    class UserController : public QObject {
        Q_OBJECT
        // 添加单例访问
        Q_PROPERTY(interface::UserController* instance READ instance CONSTANT)



    public:
        // 单例获取方法
        static UserController* instance();
        static void destroyInstance();


        // 属性（保持不变）
        Q_PROPERTY(QVariantMap currentUser READ currentUser NOTIFY currentUserChanged)
        Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY loginStatusChanged)
        Q_PROPERTY(QVariantList followingUsers READ followingUsers NOTIFY followingChanged)
        Q_PROPERTY(QVariantList followerUsers READ followerUsers NOTIFY followersChanged)
        Q_PROPERTY(QVariantList favoriteVideos READ favoriteVideos NOTIFY favoritesChanged)
        Q_PROPERTY(QVariantList watchHistory READ watchHistory NOTIFY historyChanged)
        Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

        Q_PROPERTY(qint64 avatarTimestamp READ avatarTimestamp NOTIFY avatarUrlChanged)

        Q_PROPERTY(QString avatarUrl READ avatarUrl NOTIFY avatarUrlChanged)

        // 检查是否已收藏
        Q_INVOKABLE bool isVideoFavorited(const QString& videoId) const;

    public:
        // 用户管理
        Q_INVOKABLE void registerUser(const QString& account,
                                      const QString& password,
                                      const QString& nickname,
                                      const QString& avatarUrl = "");
        Q_INVOKABLE void login(const QString& account, const QString& password);
        Q_INVOKABLE void logout();

        // 用户操作
        Q_INVOKABLE void updateProfile(const QString& nickname,
                                       const QString& signature,
                                       const QString& avatarUrl);
        Q_INVOKABLE void changePassword(const QString& newPassword);

        // 会员操作
        Q_INVOKABLE void activatePremium(int months = 1);
        Q_INVOKABLE void cancelPremium();

        // 关注关系
        Q_INVOKABLE void followUser(const QString& userId);
        Q_INVOKABLE void unfollowUser(const QString& userId);
        Q_INVOKABLE bool isFollowing(const QString& userId);

        // 内容操作
        Q_INVOKABLE void addFavoriteVideo(const QString& videoId);
        Q_INVOKABLE void removeFavoriteVideo(const QString& videoId);
        Q_INVOKABLE void addWatchHistory(const QString& videoId,
                                         const QString& videoTitle = "",
                                         const QString& coverUrl = "");
        Q_INVOKABLE void clearWatchHistory();
        Q_INVOKABLE void addCreatedVideo(const QString& videoId);

        Q_INVOKABLE void toggleLikeVideo(const QString& videoId); // 合并点赞/取消点赞
        Q_INVOKABLE bool isVideoLiked(const QString& videoId) const;

        Q_INVOKABLE void addVideoCoin(const QString& videoId);
        Q_INVOKABLE int getUserVideoCoinCount(const QString& videoId);




        // 查询
        Q_INVOKABLE QVariantMap getUserById(const QString& userId);
        Q_INVOKABLE QVariantMap getUserByAccount(const QString& account);
        Q_INVOKABLE void loadFollowingUsers();
        Q_INVOKABLE void loadFollowerUsers();
        Q_INVOKABLE void loadFavoriteVideos();
        Q_INVOKABLE void loadWatchHistory();

        // 属性访问器
        QVariantMap currentUser() const { return m_currentUser; }
        bool isLoggedIn() const { return !m_currentUserId.empty(); }
        QVariantList followingUsers() const { return m_following; }
        QVariantList followerUsers() const { return m_followers; }
        QVariantList favoriteVideos() const { return m_favoriteVideos; }
        QVariantList watchHistory() const { return m_watchHistory; }
        bool loading() const { return m_loading; }
        QString avatarUrl() const;  


        // 单例实例访问器
        //static UserController* instance() { return m_instance; }

    signals:
        void currentUserChanged();
        void loginStatusChanged();
        void followingChanged();
        void followersChanged();
        void favoritesChanged();
        void historyChanged();
        void loadingChanged();
        void errorOccurred(const QString& message);
        void registrationSuccess(const QString& userId);
        void loginSuccess(const QString& userId);
        void logoutSuccess();
        void profileUpdated();
        void passwordChanged();
        void premiumActivated();
        void premiumCanceled();
        void userFollowed(const QString& userId);
        void userUnfollowed(const QString& userId);
        void favoriteAdded(const QString& videoId);
        void favoriteRemoved(const QString& videoId);
        void historyAdded(const QString& videoId);
        void historyCleared();
        void videoLiked(const QString& videoId);
        void videoUnliked(const QString& videoId);
        void videoCoined(const QString& videoId, int coinCount);

        void avatarUrlChanged();



    private:
        // 私有构造函数
        explicit UserController(QObject* parent = nullptr);
        ~UserController();

        void removeFavoriteFromLocalList(const QString& videoId);

        QSet<QString> m_watchedVideoIds;
        QVariantList m_likedVideos; // 用户点赞的视频列表
        QMap<QString, int> m_userVideoCoins;


        qint64 m_avatarTimestamp = 0;
        qint64 avatarTimestamp() const { return m_avatarTimestamp; }


        // 禁止拷贝和赋值
        UserController(const UserController&) = delete;
        UserController& operator=(const UserController&) = delete;


        application::UserServiceController m_service;

        std::string m_currentUserId;
        QVariantMap m_currentUser;
        QVariantList m_following;
        QVariantList m_followers;
        QVariantList m_favoriteVideos;
        QVariantList m_watchHistory;
        bool m_loading = false;

        // 静态单例实例
        static UserController* m_instance;

        void setLoading(bool loading);
        void setCurrentUser(const domain::vo::UserVO& user);
        void updateCurrentUser(const domain::vo::UserVO& user);
        QVariantList userVOListToVariantList(const std::vector<domain::vo::UserVO>& users);
        QVariantList stringListToVariantList(const std::vector<std::string>& strings);
    };
}
