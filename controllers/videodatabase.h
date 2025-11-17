#pragma once

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QVariantList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>  // 添加这行
#include <QHash>

class VideoDatabase : public QObject
{
    Q_OBJECT

public:
    static VideoDatabase* getInstance();  // 修改为 getInstance

    // 数据库连接管理
    bool connectToDatabase(const QString &host, int port, const QString &database,
                           const QString &username, const QString &password);
    void disconnectDatabase();
    bool isConnected() const;

    // 表管理
    bool createVideoTable();
    bool createCommentTable();

    // 视频数据操作
    bool insertVideo(const QVariantMap &videoData);
    bool updateVideo(const QString &videoId, const QVariantMap &updateData);
    bool deleteVideo(const QString &videoId);
    QVariantMap getVideoById(const QString &videoId);
    QVariantList getAllVideos();

    // 评论数据操作
    bool insertComment(const QString &videoId, const QVariantMap &commentData);
    bool deleteComment(const QString &commentId);
    QVariantList getCommentsByVideoId(const QString &videoId);

    // 统计数据操作
    bool updateVideoStats(const QString &videoId, const QString &field, int newValue);
    bool incrementVideoStats(const QString &videoId, const QString &field, int increment = 1);

signals:
    void databaseConnected(bool success);
    void databaseError(const QString &error);
    void videoDataChanged(const QString &videoId);

private:
    explicit VideoDatabase(QObject *parent = nullptr);
    ~VideoDatabase();

    QSqlDatabase m_database;
    bool m_isConnected = false;

    // 数据库配置
    QString m_host;
    int m_port;
    QString m_databaseName;
    QString m_username;
    QString m_password;

    // 字段映射
    QHash<QString, QString> m_videoFieldMap;

    void initializeFieldMap();
    QString mapFieldName(const QString &field) const;
};
