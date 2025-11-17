#pragma once

#include <QObject>
#include <QString>
#include <QMap>
#include <QHash>
#include <QVariant>
#include <QVariantList>
#include "../vedio.h"
#include "videodatabase.h"

class VideoManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int currentViews READ currentViews NOTIFY viewsChanged)
    Q_PROPERTY(QVariantList videoList READ videoList NOTIFY videoListChanged)

public:
    explicit VideoManager(QObject *parent = nullptr);

    Q_INVOKABLE void increaseViews(const QString &videoId, int currentViews);   //增加播放量

    Q_INVOKABLE void increaseLikes(const QString &videoId, int currentLikes);   //增加点赞

    Q_INVOKABLE void increaseCoin(const QString &videoId, int currentCoin);   //增加硬币

    Q_INVOKABLE void increaseCollect(const QString &videoId, int currentCollect);   //增加收藏
    Q_INVOKABLE void increaseDownload(const QString &videoId);   //缓存

    Q_INVOKABLE void increaseForward(const QString &videoId, int currentForward);   //增加转发

    Q_INVOKABLE QVariantMap getVideoData(const QString& videoId);    //获取当前视频信息

    int currentViews() const { return m_currentViews; }

    QVariantList videoList() const;    //获取视频列表

    //评论相关
    Q_INVOKABLE void addCommentToVideo(const QString &videoId, const QString &userName, const QString &content);
    Q_INVOKABLE void addReplyToComment(const QString &videoId, const QString &parentCommentId,
                                       const QString &userName, const QString &content);
    Q_INVOKABLE QVariantList getVideoComments(const QString &videoId);

    // 视频管理功能
    Q_INVOKABLE bool initializeVideos();  // 初始化视频数据
    Q_INVOKABLE bool uploadVideo(const QVariantMap &videoInfo);  // 上传新视频
    Q_INVOKABLE bool deleteVideo(const QString &videoId);  // 删除视频

signals:
    void viewsChanged(const QString &videoId, int newViews);
    void videoListChanged();
    void commentsChanged(const QString &videoId);

    void videoUploaded(const QString &videoId);
    void videoDeleted(const QString &videoId);
    void databaseConnectionChanged(bool connected);

private:
    int m_currentViews = 0;
    QHash<QString, Vedio*> m_videos; // 存储视频

    VideoDatabase* m_videoDB;
    bool m_databaseConnected = false;
    QVariantMap videoToMap(Vedio* video) const;
    bool createLocalTestVideos();  // 创建本地测试视频
    bool loadVideosFromDatabase(); // 从数据库加载视频
    bool insertTestVideosToDatabase(); // 插入测试视频到数据库
    void updateVideoInMemory(Vedio* video, const QVariantMap &videoData); // 更新内存中的视频数据
};
