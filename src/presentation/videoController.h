#pragma once
#include <QObject>
#include <QVariant>
#include "../application/videoServerContorller.h"

namespace interface {

    class VideoController : public QObject {
        Q_OBJECT

        // 简单属性
        Q_PROPERTY(QVariantList videos READ videos NOTIFY videosChanged)
        Q_PROPERTY(QVariantList comments READ comments NOTIFY commentsChanged)
        Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
        Q_PROPERTY(int commentCount READ commentCount NOTIFY commentCountChanged)

    public:
        VideoController(QObject* parent = nullptr);

        // 核心方法
        Q_INVOKABLE void createVideo(const QString& title,
                                     const QString& author,
                                     const QString& description,
                                     const QString& videoUrl,
                                     const QString& coverUrl,
                                     const QString& headUrl);

        Q_INVOKABLE void addView(const QString& videoId);
        Q_INVOKABLE void addLike(const QString& videoId);
        Q_INVOKABLE void addCoin(const QString& videoId);
        Q_INVOKABLE void addCollection(const QString& videoId);
        Q_INVOKABLE void setDownload(const QString& videoId);
        Q_INVOKABLE void addForward(const QString& videoId);

        Q_INVOKABLE void loadVideos();
        Q_INVOKABLE void clearVideos();

        Q_INVOKABLE QVariantMap getVideo(const QString& videoId) const;

        Q_INVOKABLE void loadComments(const QString& videoId);
        Q_INVOKABLE void addComment(const QString& videoId,
                                    const QString& userName,
                                    const QString& content);
        Q_INVOKABLE void addReply(const QString& videoId,
                                  const QString& parentCommentId,
                                  const QString& userName,
                                  const QString& content);
        Q_INVOKABLE int getCommentCount(const QString& videoId);

        Q_INVOKABLE void likeComment(const QString& videoId, const QString& commentId);
        Q_INVOKABLE void unlikeComment(const QString& videoId, const QString& commentId);

        // 属性
        QVariantList videos() const { return m_videos; }
        QVariantList comments() const { return m_comments; }
        bool loading() const { return m_loading; }
        int commentCount() const { return m_commentCount; }

    signals:
        void videosChanged();
        void commentsChanged();
        void loadingChanged();
        void commentCountChanged();
        void errorOccurred(const QString& message);

        void commentAdded(const QString& commentId);
        void replyAdded(const QString& parentCommentId, const QString& replyId);
        void commentLiked(const QString& commentId, int newLikeCount);
        void commentUnliked(const QString& commentId, int newUnlikeCount);

    private:
        application::VideoServiceController m_service;
        QVariantList m_videos;
        QVariantList m_comments;
        bool m_loading = false;
        int m_commentCount = 0;

        QString m_currentVideoId;

        void setLoading(bool loading);
        void setCommentCount(int count);
        void updateData(const domain::vo::VideoVO& update);
    };

}
