#include "videodatabase.h"
#include <QDebug>
#include <QDateTime>
#include <QSqlRecord>  // 添加这行

VideoDatabase::VideoDatabase(QObject *parent)
    : QObject(parent)
    , m_port(3306)
{
    initializeFieldMap();
}

VideoDatabase::~VideoDatabase()
{
    disconnectDatabase();
}

VideoDatabase* VideoDatabase::getInstance()
{
    static VideoDatabase instance;
    return &instance;
}

void VideoDatabase::initializeFieldMap()
{
    // 映射 Vedio 类字段到数据库字段
    m_videoFieldMap = {
        {"videoId", "video_id"},
        {"title", "title"},
        {"author", "author"},
        {"description", "description"},
        {"uploadDate", "upload_date"},
        {"viewCount", "view_count"},
        {"likeCount", "like_count"},
        {"coinCount", "coin_count"},
        {"collectionCount", "collection_count"},
        {"downloaded", "downloaded"},
        {"forwardCount", "forward_count"},
        {"bulletCount", "bullet_count"},
        {"followerCount", "follower_count"},
        {"commitCount", "commit_count"},
        {"videoUrl", "video_url"},
        {"coverUrl", "cover_url"},
        {"headUrl", "head_url"}
    };
}

QString VideoDatabase::mapFieldName(const QString &field) const
{
    return m_videoFieldMap.value(field, field);
}

bool VideoDatabase::connectToDatabase(const QString &host, int port, const QString &database,
                                      const QString &username, const QString &password)
{
    m_host = host;
    m_port = port;
    m_databaseName = database;
    m_username = username;
    m_password = password;

    // 关闭现有连接
    if (m_database.isOpen()) {
        m_database.close();
    }

    // 创建新的数据库连接
    m_database = QSqlDatabase::addDatabase("QMYSQL", "video_connection");
    m_database.setHostName(host);
    m_database.setPort(port);
    m_database.setDatabaseName(database);
    m_database.setUserName(username);
    m_database.setPassword(password);

    if (!m_database.open()) {
        QSqlError error = m_database.lastError();
        qWarning() << "Failed to connect to database:";
        qWarning() << "  Error:" << error.text();
        qWarning() << "  Database:" << error.databaseText();
        qWarning() << "  Driver:" << error.driverText();
        qWarning() << "  Connection parameters:";
        qWarning() << "    Host:" << host;
        qWarning() << "    Port:" << port;
        qWarning() << "    Database:" << database;
        qWarning() << "    Username:" << username;

        emit databaseError(error.text());
        m_isConnected = false;
        return false;
    }

    m_isConnected = true;
    qDebug() << "Successfully connected to database";
    emit databaseConnected(true);

    // 创建表
    if (!createVideoTable() || !createCommentTable()) {
        qWarning() << "Failed to create tables";
        return false;
    }

    return true;
}

void VideoDatabase::disconnectDatabase()
{
    if (m_database.isOpen()) {
        m_database.close();
    }
    m_isConnected = false;
}

bool VideoDatabase::isConnected() const
{
    return m_isConnected && m_database.isOpen();
}

bool VideoDatabase::createVideoTable()
{
    if (!isConnected()) {
        qWarning() << "Database not connected";
        return false;
    }

    QString createTableSQL = R"(
        CREATE TABLE IF NOT EXISTS videos (
            video_id VARCHAR(255) PRIMARY KEY,
            title TEXT NOT NULL,
            author VARCHAR(255) NOT NULL,
            description TEXT,
            upload_date VARCHAR(100),
            view_count INT DEFAULT 0,
            like_count INT DEFAULT 0,
            coin_count INT DEFAULT 0,
            collection_count INT DEFAULT 0,
            downloaded BOOLEAN DEFAULT FALSE,
            forward_count INT DEFAULT 0,
            bullet_count INT DEFAULT 0,
            follower_count INT DEFAULT 0,
            commit_count INT DEFAULT 0,
            video_url TEXT,
            cover_url TEXT,
            head_url TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    )";

    QSqlQuery query(m_database);
    if (!query.exec(createTableSQL)) {
        qWarning() << "Failed to create videos table:" << query.lastError().text();
        return false;
    }

    qDebug() << "Videos table created or already exists";
    return true;
}

bool VideoDatabase::createCommentTable()
{
    if (!isConnected()) {
        qWarning() << "Database not connected";
        return false;
    }

    QString createTableSQL = R"(
        CREATE TABLE IF NOT EXISTS comments (
            comment_id VARCHAR(255) PRIMARY KEY,
            video_id VARCHAR(255) NOT NULL,
            user_name VARCHAR(255) NOT NULL,
            content TEXT NOT NULL,
            parent_comment_id VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (video_id) REFERENCES videos(video_id) ON DELETE CASCADE,
            INDEX idx_video_id (video_id),
            INDEX idx_parent_comment_id (parent_comment_id)
        )
    )";

    QSqlQuery query(m_database);
    if (!query.exec(createTableSQL)) {
        qWarning() << "Failed to create comments table:" << query.lastError().text();
        return false;
    }

    qDebug() << "Comments table created or already exists";
    return true;
}

bool VideoDatabase::insertVideo(const QVariantMap &videoData)
{
    if (!isConnected()) {
        qWarning() << "Database not connected";
        return false;
    }

    QStringList fields;
    QStringList placeholders;
    QList<QVariant> values;

    for (auto it = videoData.begin(); it != videoData.end(); ++it) {
        QString dbField = mapFieldName(it.key());
        fields.append(dbField);
        placeholders.append("?");
        values.append(it.value());
    }

    QString sql = QString("INSERT INTO videos (%1) VALUES (%2)")
                      .arg(fields.join(", "))
                      .arg(placeholders.join(", "));

    QSqlQuery query(m_database);
    query.prepare(sql);

    for (const QVariant &value : values) {
        query.addBindValue(value);
    }

    if (!query.exec()) {
        qWarning() << "Failed to insert video:" << query.lastError().text();
        return false;
    }

    qDebug() << "Video inserted successfully:" << videoData["videoId"].toString();
    emit videoDataChanged(videoData["videoId"].toString());
    return true;
}

bool VideoDatabase::updateVideo(const QString &videoId, const QVariantMap &updateData)
{
    if (!isConnected()) {
        qWarning() << "Database not connected";
        return false;
    }

    if (updateData.isEmpty()) {
        return true;
    }

    QStringList setClauses;
    QList<QVariant> values;

    for (auto it = updateData.begin(); it != updateData.end(); ++it) {
        QString dbField = mapFieldName(it.key());
        setClauses.append(QString("%1 = ?").arg(dbField));
        values.append(it.value());
    }

    values.append(videoId);

    QString sql = QString("UPDATE videos SET %1 WHERE video_id = ?")
                      .arg(setClauses.join(", "));

    QSqlQuery query(m_database);
    query.prepare(sql);

    for (const QVariant &value : values) {
        query.addBindValue(value);
    }

    if (!query.exec()) {
        qWarning() << "Failed to update video:" << query.lastError().text();
        return false;
    }

    qDebug() << "Video updated successfully:" << videoId;
    emit videoDataChanged(videoId);
    return true;
}

bool VideoDatabase::deleteVideo(const QString &videoId)
{
    if (!isConnected()) {
        qWarning() << "Database not connected";
        return false;
    }

    QSqlQuery query(m_database);
    query.prepare("DELETE FROM videos WHERE video_id = ?");
    query.addBindValue(videoId);

    if (!query.exec()) {
        qWarning() << "Failed to delete video:" << query.lastError().text();
        return false;
    }

    qDebug() << "Video deleted successfully:" << videoId;
    return true;
}

QVariantMap VideoDatabase::getVideoById(const QString &videoId)
{
    QVariantMap result;

    if (!isConnected()) {
        qWarning() << "Database not connected";
        return result;
    }

    QSqlQuery query(m_database);
    query.prepare("SELECT * FROM videos WHERE video_id = ?");
    query.addBindValue(videoId);

    if (!query.exec() || !query.next()) {
        qWarning() << "Failed to get video or video not found:" << videoId;
        return result;
    }

    QSqlRecord record = query.record();
    for (int i = 0; i < record.count(); ++i) {
        result[record.fieldName(i)] = query.value(i);
    }

    return result;
}

QVariantList VideoDatabase::getAllVideos()
{
    QVariantList result;

    if (!isConnected()) {
        qWarning() << "Database not connected";
        return result;
    }

    QSqlQuery query("SELECT * FROM videos ORDER BY created_at DESC", m_database);

    while (query.next()) {
        QVariantMap videoData;
        QSqlRecord record = query.record();
        for (int i = 0; i < record.count(); ++i) {
            videoData[record.fieldName(i)] = query.value(i);
        }
        result.append(videoData);
    }

    return result;
}

bool VideoDatabase::insertComment(const QString &videoId, const QVariantMap &commentData)
{
    if (!isConnected()) {
        qWarning() << "Database not connected";
        return false;
    }

    QSqlQuery query(m_database);
    query.prepare("INSERT INTO comments (comment_id, video_id, user_name, content, parent_comment_id) "
                  "VALUES (?, ?, ?, ?, ?)");
    query.addBindValue(commentData["commentId"]);
    query.addBindValue(videoId);
    query.addBindValue(commentData["userName"]);
    query.addBindValue(commentData["content"]);
    // 修复过时的构造函数
    query.addBindValue(commentData.value("parentCommentId", QVariant()));

    if (!query.exec()) {
        qWarning() << "Failed to insert comment:" << query.lastError().text();
        return false;
    }

    // 更新视频的评论计数
    incrementVideoStats(videoId, "commitCount");

    return true;
}

QVariantList VideoDatabase::getCommentsByVideoId(const QString &videoId)
{
    QVariantList result;

    if (!isConnected()) {
        qWarning() << "Database not connected";
        return result;
    }

    QSqlQuery query(m_database);
    query.prepare("SELECT * FROM comments WHERE video_id = ? ORDER BY created_at ASC");
    query.addBindValue(videoId);

    if (!query.exec()) {
        qWarning() << "Failed to get comments:" << query.lastError().text();
        return result;
    }

    while (query.next()) {
        QVariantMap commentData;
        QSqlRecord record = query.record();
        for (int i = 0; i < record.count(); ++i) {
            commentData[record.fieldName(i)] = query.value(i);
        }
        result.append(commentData);
    }

    return result;
}

bool VideoDatabase::updateVideoStats(const QString &videoId, const QString &field, int newValue)
{
    QString dbField = mapFieldName(field);
    QString sql = QString("UPDATE videos SET %1 = ? WHERE video_id = ?").arg(dbField);

    QSqlQuery query(m_database);
    query.prepare(sql);
    query.addBindValue(newValue);
    query.addBindValue(videoId);

    if (!query.exec()) {
        qWarning() << "Failed to update video stats:" << query.lastError().text();
        return false;
    }

    emit videoDataChanged(videoId);
    return true;
}

bool VideoDatabase::incrementVideoStats(const QString &videoId, const QString &field, int increment)
{
    QString dbField = mapFieldName(field);
    QString sql = QString("UPDATE videos SET %1 = %1 + ? WHERE video_id = ?").arg(dbField);

    QSqlQuery query(m_database);
    query.prepare(sql);
    query.addBindValue(increment);
    query.addBindValue(videoId);

    if (!query.exec()) {
        qWarning() << "Failed to increment video stats:" << query.lastError().text();
        return false;
    }

    emit videoDataChanged(videoId);
    return true;
}
