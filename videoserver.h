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
    QString videoId;
    QString title;
    QString description;
    QString videoUrl;
    QString coverUrl;
    QString duration;
    int views;
    QString fileSize;
    QString originalFileName;
    QString cosKey;
    QString uploadTime;

    QJsonObject toJson() const {
        return QJsonObject{
            {"videoId", videoId},
            {"title", title},
            {"description", description},
            {"videoUrl", videoUrl},
            {"coverUrl", coverUrl},
            {"duration", duration},
            {"views", views},
            {"fileSize", fileSize},
            {"originalFileName", originalFileName},
            {"cosKey", cosKey},
            {"uploadTime", uploadTime}
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
