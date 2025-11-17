#include "videomanager.h"
#include <QDebug>

VideoManager::VideoManager(QObject* parent) :
    QObject(parent)
    ,m_videoDB(VideoDatabase::getInstance())
{
    m_databaseConnected =  m_videoDB->connectToDatabase(
        "cq-cdb-82wznfkj.sql.tencentcdb.com",
        22290,
        "bilibili_db",
        "root",
        "12345678n"
        );

    emit databaseConnectionChanged(m_databaseConnected);

    if (m_databaseConnected) {
        qDebug() << "✅ 视频数据库连接成功！";
        // 连接成功，初始化视频数据
        initializeVideos();
    } else {
        qDebug() << "❌ 视频数据库连接失败！";
        // 连接失败，创建本地测试视频
        createLocalTestVideos();
    }

}

// 初始化视频数据
bool VideoManager::initializeVideos()
{
    if (m_databaseConnected) {
        // 尝试从数据库加载视频
        if (loadVideosFromDatabase()) {
            qDebug() << "✅ 从数据库成功加载视频数据";
            return true;
        } else {
            qDebug() << "❌ 从数据库加载视频失败，插入测试数据";
            if (insertTestVideosToDatabase()) {
                return loadVideosFromDatabase(); // 重新加载
            }
        }
    }

    // 如果数据库不可用，使用本地数据
    qDebug() << "使用本地测试视频数据";
    return createLocalTestVideos();
}

// 上传新视频
bool VideoManager::uploadVideo(const QVariantMap &videoInfo)
{
    if (!m_databaseConnected) {
        qWarning() << "数据库未连接，无法上传视频";
        return false;
    }

    // 生成视频ID
    QString videoId = Vedio::generateUniqueId();

    // 准备视频数据
    QVariantMap videoData;
    videoData["videoId"] = videoId;
    videoData["title"] = videoInfo.value("title", "未命名视频").toString();
    videoData["author"] = videoInfo.value("author", "未知作者").toString();
    videoData["description"] = videoInfo.value("description", "").toString();
    videoData["uploadDate"] = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
    videoData["viewCount"] = 0;
    videoData["likeCount"] = 0;
    videoData["coinCount"] = 0;
    videoData["collectionCount"] = 0;
    videoData["downloaded"] = false;
    videoData["forwardCount"] = 0;
    videoData["bulletCount"] = 0;
    videoData["followerCount"] = 0;
    videoData["commitCount"] = 0;
    videoData["videoUrl"] = videoInfo.value("videoUrl", "").toString();
    videoData["coverUrl"] = videoInfo.value("coverUrl", "").toString();
    videoData["headUrl"] = videoInfo.value("headUrl", "").toString();

    // 插入到数据库
    if (m_videoDB->insertVideo(videoData)) {
        // 创建本地视频对象
        Vedio* video = new Vedio(this);
        updateVideoInMemory(video, videoData);
        m_videos[videoId] = video;

        emit videoUploaded(videoId);
        emit videoListChanged();

        qDebug() << "✅ 视频上传成功:" << videoData["title"].toString();
        return true;
    } else {
        qDebug() << "❌ 视频上传失败";
        return false;
    }
}

// 删除视频
bool VideoManager::deleteVideo(const QString &videoId)
{
    if (!m_databaseConnected) {
        qWarning() << "数据库未连接，无法删除视频";
        return false;
    }

    if (m_videos.contains(videoId)) {
        // 从数据库删除
        if (m_videoDB->deleteVideo(videoId)) {
            // 从内存删除
            Vedio* video = m_videos.take(videoId);
            if (video) {
                video->deleteLater();
            }

            emit videoDeleted(videoId);
            emit videoListChanged();

            qDebug() << "✅ 视频删除成功:" << videoId;
            return true;
        }
    }

    qDebug() << "❌ 视频删除失败，视频不存在:" << videoId;
    return false;
}

// 从数据库加载视频
bool VideoManager::loadVideosFromDatabase()
{
    QVariantList videosData = m_videoDB->getAllVideos();

    if (videosData.isEmpty()) {
        qDebug() << "数据库中没有视频数据";
        return false;
    }

    // 清空现有视频
    qDeleteAll(m_videos);
    m_videos.clear();

    // 从数据库数据创建视频对象
    for (const QVariant &videoVar : videosData) {
        QVariantMap videoData = videoVar.toMap();

        Vedio* video = new Vedio(this);
        updateVideoInMemory(video, videoData);
        m_videos[video->videoId()] = video;
    }

    qDebug() << "✅ 从数据库加载了" << m_videos.size() << "个视频";
    emit videoListChanged();
    return true;
}

// 插入测试视频到数据库  （可删除
bool VideoManager::insertTestVideosToDatabase()
{
    // 测试视频1
    QVariantMap video1Data;
    video1Data["videoId"] = "test_video_001";
    video1Data["title"] = "本地测试视频";
    video1Data["author"] = "菜须坤";
    video1Data["description"] = "这是一个本地测试视频";
    video1Data["uploadDate"] = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
    video1Data["viewCount"] = 0;
    video1Data["likeCount"] = 0;
    video1Data["coinCount"] = 0;
    video1Data["collectionCount"] = 0;
    video1Data["downloaded"] = false;
    video1Data["forwardCount"] = 0;
    video1Data["bulletCount"] = 0;
    video1Data["followerCount"] = 0;
    video1Data["commitCount"] = 0;
    video1Data["videoUrl"] = "file:///root/tmp/a.mkv";
    video1Data["coverUrl"] = "qrc:/images/local_video_cover.jpg";
    video1Data["headUrl"] = "";

    // 测试视频2
    QVariantMap video2Data;
    video2Data["videoId"] = "test_video_002";
    video2Data["title"] = "Qt Quick教程";
    video2Data["author"] = "Qt大师";
    video2Data["description"] = "Qt Quick开发教程";
    video2Data["uploadDate"] = QDateTime::currentDateTime().addDays(-1).toString("yyyy-MM-dd HH:mm:ss");
    video2Data["viewCount"] = 100;
    video2Data["likeCount"] = 0;
    video2Data["coinCount"] = 0;
    video2Data["collectionCount"] = 0;
    video2Data["downloaded"] = false;
    video2Data["forwardCount"] = 0;
    video2Data["bulletCount"] = 0;
    video2Data["followerCount"] = 0;
    video2Data["commitCount"] = 0;
    video2Data["videoUrl"] = "file:///root/tmp/a.mkv";
    video2Data["coverUrl"] = "qrc:/dimages/local_video_cover.jpg";
    video2Data["headUrl"] = "";

    bool success1 = m_videoDB->insertVideo(video1Data);
    bool success2 = m_videoDB->insertVideo(video2Data);

    if (success1 && success2) {
        qDebug() << "✅ 测试视频插入成功";
        return true;
    } else {
        qDebug() << "❌ 测试视频插入失败";
        return false;
    }
}

// 创建本地测试视频  （可删除
bool VideoManager::createLocalTestVideos()
{
    // 清空现有视频
    qDeleteAll(m_videos);
    m_videos.clear();

    // 创建视频1
    Vedio* video1 = new Vedio(this);
    video1->setTitle("本地测试视频");
    video1->setAuthor("菜须坤");
    video1->setViewCount(0);
    video1->setVideoUrl("file:///root/tmp/a.mkv");
    video1->setCoverUrl("qrc:/images/local_video_cover.jpg");
    m_videos[video1->videoId()] = video1;

    // 创建视频2
    Vedio* video2 = new Vedio(this);
    video2->setTitle("Qt Quick教程");
    video2->setAuthor("Qt大师");
    video2->setViewCount(100);
    video2->setVideoUrl("file:///root/tmp/a.mkv");
    video2->setCoverUrl("qrc:/dimages/local_video_cover.jpg");
    m_videos[video2->videoId()] = video2;

    qDebug() << "✅ 创建了" << m_videos.size() << "个本地测试视频";
    emit videoListChanged();
    return true;
}

// 更新内存中的视频数据 (简便操作
void VideoManager::updateVideoInMemory(Vedio* video, const QVariantMap &videoData)
{
    if (!video) return;

    video->setId(videoData["video_id"].toString());
    video->setTitle(videoData["title"].toString());
    video->setAuthor(videoData["author"].toString());
    video->setDescription(videoData["description"].toString());
    video->setUploadDate(videoData["upload_date"].toString());
    video->setViewCount(videoData["view_count"].toInt());
    video->setLikeCount(videoData["like_count"].toInt());
    video->setCoinCount(videoData["coin_count"].toInt());
    video->setCollectionCount(videoData["collection_count"].toInt());
    video->setDownloaded(videoData["downloaded"].toBool());
    video->setForwardCount(videoData["forward_count"].toInt());
    video->setBulletCount(videoData["bullet_count"].toInt());
    video->setFollower(videoData["follower_count"].toInt());
    video->setCommitCount(videoData["commit_count"].toInt());
    video->setVideoUrl(videoData["video_url"].toString());
    video->setCoverUrl(videoData["cover_url"].toString());
    video->setHeadUrl(videoData["head_url"].toString());
}

QVariantMap VideoManager::videoToMap(Vedio* video) const
{
    QVariantMap videoData;
    if (!video) return videoData;

    videoData["videoId"] = video->videoId();
    videoData["title"] = video->title();
    videoData["author"] = video->author();
    videoData["description"] = video->description();
    videoData["uploadDate"] = video->uploadDate();
    videoData["viewCount"] = video->viewCount();
    videoData["likeCount"] = video->likeCount();
    videoData["coinCount"] = video->coinCount();
    videoData["collectionCount"] = video->collectionCount();
    videoData["downloaded"] = video->downloaded();
    videoData["forwardCount"] = video->forwardCount();
    videoData["bulletCount"] = video->bulletCount();
    videoData["followerCount"] = video->followerCount();
    videoData["commitCount"] = video->commitCount();
    videoData["videoUrl"] = video->videoUrl();
    videoData["coverUrl"] = video->coverUrl();
    videoData["headUrl"] = video->headUrl();

    return videoData;
}

void VideoManager::increaseViews(const QString &videoId, int currentViews)
{
    if (!m_videos.contains(videoId)) {
        qWarning() << "❌ 视频不存在，ID:" << videoId;
        return;
    }

    Vedio* video = m_videos.value(videoId);
    if (!video) {
        qCritical() << "❌ 视频指针为空，ID:" << videoId;
        return;
    }

    // 更新本地内存
    int newViews = video->viewCount() + 1;
    video->setViewCount(newViews);

    // 更新数据库
    if (m_databaseConnected) {
        if (!m_videoDB->incrementVideoStats(videoId, "viewCount", 1)) {
            qWarning() << "❌ 数据库更新播放量失败";
        }
    }

    // 发出信号
    emit viewsChanged(videoId, newViews);
    emit videoListChanged();

    qDebug() << "✅ 播放量增加: 视频" << videoId << "新播放量:" << newViews;
}

void VideoManager::increaseLikes(const QString& videoId, int currentLikes)
{
    if (!m_videos.contains(videoId)) {
        qWarning() << "❌ 视频不存在，ID:" << videoId;
        return;
    }

    Vedio* video = m_videos.value(videoId);
    if (!video) {
        qCritical() << "❌ 视频指针为空，ID:" << videoId;
        return;
    }

    // 更新本地内存
    int newLikes = video->likeCount() + 1;
    video->setLikeCount(newLikes);

    // 更新数据库
    if (m_databaseConnected) {
        if (!m_videoDB->incrementVideoStats(videoId, "likeCount", 1)) {
            qWarning() << "❌ 数据库更新点赞数失败";
        }
    }

    // 发出信号
    emit videoListChanged();

    qDebug() << "✅ 点赞增加: 视频" << videoId << "新点赞数:" << newLikes;
}

void VideoManager::increaseCoin(const QString& videoId, int currentCoin)
{
    if (!m_videos.contains(videoId)) {
        qWarning() << "❌ 视频不存在，ID:" << videoId;
        return;
    }

    Vedio* video = m_videos.value(videoId);
    if (!video) {
        qCritical() << "❌ 视频指针为空，ID:" << videoId;
        return;
    }

    // 更新本地内存
    int newCoin = video->coinCount() + 1;
    video->setCoinCount(newCoin);

    // 更新数据库
    if (m_databaseConnected) {
        if (!m_videoDB->incrementVideoStats(videoId, "coinCount", 1)) {
            qWarning() << "❌ 数据库更新硬币数失败";
        }
    }

    // 发出信号
    emit videoListChanged();

    qDebug() << "✅ 硬币增加: 视频" << videoId << "新硬币数:" << newCoin;
}

void VideoManager::increaseCollect(const QString& videoId, int currentCollect)
{
    if (!m_videos.contains(videoId)) {
        qWarning() << "❌ 视频不存在，ID:" << videoId;
        return;
    }

    Vedio* video = m_videos.value(videoId);
    if (!video) {
        qCritical() << "❌ 视频指针为空，ID:" << videoId;
        return;
    }

    // 更新本地内存
    int newCollect = video->collectionCount() + 1;
    video->setCollectionCount(newCollect);

    // 更新数据库
    if (m_databaseConnected) {
        if (!m_videoDB->incrementVideoStats(videoId, "collectionCount", 1)) {
            qWarning() << "❌ 数据库更新收藏数失败";
        }
    }

    // 发出信号
    emit videoListChanged();

    qDebug() << "✅ 收藏增加: 视频" << videoId << "新收藏数:" << newCollect;
}

void VideoManager::increaseDownload(const QString& videoId)
{
    if (!m_videos.contains(videoId)) {
        qWarning() << "❌ 视频不存在，ID:" << videoId;
        return;
    }

    Vedio* video = m_videos.value(videoId);
    if (!video) {
        qCritical() << "❌ 视频指针为空，ID:" << videoId;
        return;
    }

    // 更新本地内存
    bool newDownloaded = !video->downloaded(); // 切换下载状态
    video->setDownloaded(newDownloaded);

    // 更新数据库
    if (m_databaseConnected) {
        QVariantMap updateData;
        updateData["downloaded"] = newDownloaded;
        if (!m_videoDB->updateVideo(videoId, updateData)) {
            qWarning() << "❌ 数据库更新下载状态失败";
        }
    }

    // 发出信号
    emit videoListChanged();

    qDebug() << "✅ 下载状态更新: 视频" << videoId << "下载状态:" << newDownloaded;
}

void VideoManager::increaseForward(const QString& videoId, int currentForward)
{
    if (!m_videos.contains(videoId)) {
        qWarning() << "❌ 视频不存在，ID:" << videoId;
        return;
    }

    Vedio* video = m_videos.value(videoId);
    if (!video) {
        qCritical() << "❌ 视频指针为空，ID:" << videoId;
        return;
    }

    // 更新本地内存
    int newForward = video->forwardCount() + 1;
    video->setForwardCount(newForward);

    // 更新数据库
    if (m_databaseConnected) {
        if (!m_videoDB->incrementVideoStats(videoId, "forwardCount", 1)) {
            qWarning() << "❌ 数据库更新转发数失败";
        }
    }

    // 发出信号
    emit videoListChanged();

    qDebug() << "✅ 转发增加: 视频" << videoId << "新转发数:" << newForward;
}

QVariantMap VideoManager::getVideoData(const QString& videoId)
{
    if (!m_videos.contains(videoId)) {
        qWarning() << "视频不存在:" << videoId;
        return QVariantMap();
    }

    Vedio* video = m_videos.value(videoId);
    if (!video) {
        qCritical() << "视频指针为空:" << videoId;
        return QVariantMap();
    }

    // 直接使用 videoToMap 函数，避免代码重复
    return videoToMap(video);
}


QVariantList VideoManager::videoList() const {
    QVariantList list;
    for (Vedio* video : m_videos) {
        // 将 Vedio 对象指针转换为 QVariant
        list.append(QVariant::fromValue(video));
    }
    return list;
}

void VideoManager::addCommentToVideo(const QString &videoId, const QString &userName, const QString &content) {
    if (m_videos.contains(videoId)) {
        Vedio* video = m_videos.value(videoId);
        video->addComment(userName, content);
        emit commentsChanged(videoId);
        qDebug() << "为视频" << videoId << "添加评论，用户:" << userName;
    } else {
        qWarning() << "视频不存在，无法添加评论:" << videoId;
    }
}

void VideoManager::addReplyToComment(const QString &videoId, const QString &parentCommentId,
                                     const QString &userName, const QString &content) {
    if (m_videos.contains(videoId)) {
        Vedio* video = m_videos.value(videoId);
        video->addReply(parentCommentId, userName, content);
        emit commentsChanged(videoId);
        qDebug() << "为视频" << videoId << "的评论" << parentCommentId << "添加回复";
    } else {
        qWarning() << "视频不存在，无法添加回复:" << videoId;
    }
}

QVariantList VideoManager::getVideoComments(const QString &videoId) {
    QVariantList commentsList;

    if (m_videos.contains(videoId)) {
        Vedio* video = m_videos.value(videoId);
        QList<QObject*> comments = video->comments();

        for (QObject* commentObj : comments) {
            Comment* comment = qobject_cast<Comment*>(commentObj);
            if (comment) {
                QVariantMap commentData;
                commentData["id"] = comment->id();
                commentData["userName"] = comment->userName();
                commentData["time"] = comment->formattedTime();
                commentData["content"] = comment->content();
                commentData["likeCount"] = comment->likeCount();
                commentData["unlikeCount"] = comment->unlikeCount();
                commentData["isReply"] = comment->isReply();
                commentData["parentId"] = comment->parentId();

                // 处理回复
                QVariantList repliesList;
                QVector<Comment*> replies = comment->replies();
                for (Comment* reply : replies) {
                    QVariantMap replyData;
                    replyData["id"] = reply->id();
                    replyData["userName"] = reply->userName();
                    replyData["time"] = reply->formattedTime();
                    replyData["content"] = reply->content();
                    replyData["likeCount"] = reply->likeCount();
                    replyData["unlikeCount"] = reply->unlikeCount();
                    replyData["isReply"] = reply->isReply();
                    replyData["parentId"] = reply->parentId();
                    repliesList.append(replyData);
                }
                commentData["replies"] = repliesList;

                commentsList.append(commentData);

            }
        }

    }
    return commentsList;
}
