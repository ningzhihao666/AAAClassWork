#include "videoController.h"
#include <QDebug>

namespace interface {

    // 初始化静态成员
    VideoController* VideoController::s_instance = nullptr;

    VideoController::VideoController(QObject* parent)
        : QObject(parent)
    {
        qDebug() << "视频控制器已创建";
    }

    VideoController::~VideoController()
    {
        qDebug() << "视频控制器已销毁";
    }

    VideoController* VideoController::instance()
    {
        if (!s_instance) {
            s_instance = new VideoController();
        }
        return s_instance;
    }

    void VideoController::destroyInstance()
    {
        if (s_instance) {
            delete s_instance;
            s_instance = nullptr;
        }
    }

    void VideoController::createVideo(const QString& title,
                                      const QString& author,
                                      const QString& description,
                                      const QString& videoUrl,
                                      const QString& coverUrl,
                                      const QString& headUrl
                                      )
    {
        setLoading(true);

        // 准备视频信息
        domain::Video::Video_Info info;
        info.title = title.toStdString();
        info.author = author.toStdString();
        info.description = description.toStdString();
        info.videoUrl = videoUrl.toStdString();
        info.coverUrl = coverUrl.toStdString();
        info.headUrl = headUrl.toStdString();


        // 调用服务
        m_service.createVideo(info);

        setLoading(false);
    }

    void VideoController::addView(const QString& videoId)
    {
        m_service.addView(videoId.toStdString());

    }

    void VideoController::addLike(const QString& videoId,int count)
    {
        auto vo = m_service.addLike(videoId.toStdString(),count);
        updateData(vo);
    }

    void VideoController::addCoin(const QString& videoId)
    {
        auto vo = m_service.addCoin(videoId.toStdString());
        updateData(vo);
    }

    void VideoController::addCollection(const QString& videoId,int count)
    {
        auto vo = m_service.addCollection(videoId.toStdString(),count);
        updateData(vo);
    }

    void VideoController::setDownload(const QString& videoId)
    {
        auto vo = m_service.setDownload(videoId.toStdString());
        updateData(vo);
    }

    void VideoController::addForward(const QString& videoId)
    {
        auto vo = m_service.addForward(videoId.toStdString());
        updateData(vo);
    }

    void VideoController::loadVideos() {
        setLoading(true);

        auto dtos = m_service.getAllVideos();

        qDebug() << dtos.size();

        m_videos.clear();
        for (const auto& dto : dtos) {
            m_videos.append(dto.toVariantMap());
        }

        emit videosChanged();
        setLoading(false);

        qDebug() << "加载视频完成，共" << m_videos.size() << "个";
    }

    QVariantMap VideoController::getVideo(const QString& videoId) const {
        for (const QVariant& videoVariant : m_videos) {
            QVariantMap video = videoVariant.toMap();
            if (video["id"].toString() == videoId) {
                return video;
            }
        }

        qWarning() << "❌ 未找到视频，ID:" << videoId;
        return QVariantMap();
    }

    void VideoController::clearVideos() {
        m_videos.clear();
        emit videosChanged();
        qDebug() << "清空视频列表";
    }

    void VideoController::loadComments(const QString& videoId)
    {
        setLoading(true);
        m_currentVideoId = videoId;

        auto commentVOs = m_service.getVideoComments(videoId.toStdString());

        m_comments.clear();

        for (const auto& vo : commentVOs) {
            m_comments.append(vo.toVariantMap());
        }

        int count = m_service.getVideoCommentCount(videoId.toStdString());
        setCommentCount(count);

        emit commentsChanged();
        setLoading(false);

        qDebug() << "加载评论完成，共" << m_comments.size() << "条评论";
    }

    void VideoController::addComment(const QString& videoId, const QString& userName, const QString& content)
    {
        setLoading(true);

        // 调用服务层添加评论
        auto vo = m_service.addComment(videoId.toStdString(), content.toStdString(), userName.toStdString());

        if (vo.isValid()) {
            emit commentAdded(QString::fromStdString(vo.id));
        } else {
            emit errorOccurred("添加评论失败");
        }

        setLoading(false);
    }

    void VideoController::addReply(const QString& videoId,
                                   const QString& parentCommentId,
                                   const QString& userName,
                                   const QString& content) {

        setLoading(true);

        auto vo = m_service.addReply(videoId.toStdString(),
                                     parentCommentId.toStdString(),
                                     content.toStdString(),
                                     userName.toStdString());

        if (vo.isValid()) {
            emit replyAdded(parentCommentId, QString::fromStdString(vo.id));
        } else {
            emit errorOccurred("添加回复失败");
        }

        setLoading(false);
    }

    void VideoController::likeComment(const QString& videoId, const QString& commentId)
    {
        setLoading(true);

        m_service.likeComment(videoId.toStdString(), commentId.toStdString());

        auto commentVOs = m_service.getVideoComments(videoId.toStdString());
        for (const auto& vo : commentVOs) {
            if (vo.id == commentId.toStdString()) {
                emit commentLiked(commentId, vo.likeCount);
                break;
            }
        }
        setLoading(false);
    }

    void VideoController::unlikeComment(const QString& videoId, const QString& commentId)
    {
        setLoading(true);

        m_service.unlikeComment(videoId.toStdString(), commentId.toStdString());

        auto commentVOs = m_service.getVideoComments(videoId.toStdString());
        for (const auto& vo : commentVOs) {
            if (vo.id == commentId.toStdString()) {
                emit commentUnliked(commentId, vo.unlikeCount);
                break;
            }
        }
        setLoading(false);
    }

    int VideoController::getCommentCount(const QString& videoId) {
        return m_service.getVideoCommentCount(videoId.toStdString());
    }


    void VideoController::setLoading(bool loading) {
        if (m_loading != loading) {
            m_loading = loading;
            emit loadingChanged();
        }
    }

    void VideoController::setCommentCount(int count) {
        if (m_commentCount != count) {
            m_commentCount = count;
            emit commentCountChanged();
        }
    }

    void VideoController::updateData(const domain::vo::VideoVO& update)
    {
        for (int i = 0; i < m_videos.size(); ++i) {
            QVariantMap video = m_videos[i].toMap();
            if (video["id"].toString().toStdString() == update.id) {
                m_videos[i] = update.toVariantMap();
                emit videosChanged();
                return;
            }
        }
    }

    void VideoController::loadVideoFromDatabase()
    {
        m_service.loadVideo();
    }


}
