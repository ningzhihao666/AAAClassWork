#ifndef VIDEOSERVER_H
#define VIDEOSERVER_H

#include <QObject>
#include <QHttpServer>
#include <QJsonObject>
#include <QJsonArray>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QFile>
#include <QDir>
#include <QDateTime>
#include <QCryptographicHash>
#include <QTcpServer>
#include <QHttpServerRequest>
#include <QHttpServerResponse>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QHttpMultiPart>
#include <QBuffer>

struct VideoMetadata {
    QString id;               // 对应原 video_id
    QString title;
    QString author;           // 新增：作者
    QString description;
    QString upload_date;      // 新增：上传日期字符串
    int view_count = 0;
    int like_count = 0;
    int coin_count = 0;
    int collection_count = 0;
    bool downloaded = false;  // 新增：是否已下载
    int forward_count = 0;    // 新增：转发数
    int bullet_count = 0;     // 新增：弹幕数
    int follower_count = 0;   // 新增：粉丝数
    int commit_count = 0;     // 新增：评论数
    QString video_url;
    QString cover_url;
    QString head_url;         // 新增：头像URL

    QJsonObject toJson() const {
        return QJsonObject{
            {"id", id},
            {"title", title},
            {"author", author},
            {"description", description},
            {"upload_date", upload_date},
            {"view_count", view_count},
            {"like_count", like_count},
            {"coin_count", coin_count},
            {"collection_count", collection_count},
            {"downloaded", downloaded},
            {"forward_count", forward_count},
            {"bullet_count", bullet_count},
            {"follower_count", follower_count},
            {"commit_count", commit_count},
            {"video_url", video_url},
            {"cover_url", cover_url},
            {"head_url", head_url}
        };
    }
};

class VideoServer : public QObject
{
    Q_OBJECT

public:
    explicit VideoServer(QObject *parent = nullptr);
    ~VideoServer();

    bool startServer(quint16 port = 3000);

private slots:
    QHttpServerResponse handleHealthCheck(const QHttpServerRequest &request);
    QHttpServerResponse handleGetVideos(const QHttpServerRequest &request);
    QHttpServerResponse handleUploadByPath(const QHttpServerRequest &request);
    QHttpServerResponse handleGetVideoById(const QHttpServerRequest &request);
    QHttpServerResponse handleSearchVideos(const QHttpServerRequest &request);
    QHttpServerResponse handleTestDB(const QHttpServerRequest &request);

private:
    bool initDatabase();
    bool initVideoTable();
    bool saveVideoToDatabase(const VideoMetadata &videoData);
    QList<VideoMetadata> getVideosFromDatabase();
    VideoMetadata getVideoFromDatabase(const QString &videoId);
    QList<VideoMetadata> searchVideosByKeyword(const QString &keyword);

    // COS 上传函数
    bool uploadToCOS(const QString &fileKey, const QString &filePath, qint64 fileSize);
    void handleCOSUploadFinished(QNetworkReply *reply, const QString &fileKey,
                                 const VideoMetadata &videoData, bool isCover = false);
    QString generateCOSAuthorization(const QString &method, const QString &key);

    QString generateRandomDuration();
    QString generateRandomViews();
    int generateRandomNumber(int min, int max);

    QString formatFileSize(qint64 bytes);
    QJsonObject parseJsonBody(const QByteArray &body);

    QHttpServer *m_server;
    QSqlDatabase m_database;
    QHash<QString, VideoMetadata> m_videoMetadata;
    QNetworkAccessManager *m_networkManager;

    // COS配置
    QString m_cosSecretId = "AKIDvugHj03wc4LUTGqMflhS0Ol7KOGygIhv";
    QString m_cosSecretKey = "74sUu7JPRIxRktwoV07773seKsFPbgZF";
    QString m_cosBucket = "video-1380504831";
    QString m_cosRegion = "ap-guangzhou";

};

#endif // VIDEOSERVER_H
