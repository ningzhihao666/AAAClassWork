#include "videoserver.h"
#include <QHttpServer>
#include <QHttpServerRequest>
#include <QHttpServerResponse>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QFile>
#include <QDir>
#include <QDateTime>
#include <QRandomGenerator>
#include <QCryptographicHash>
#include <QTcpServer>
#include <QHttpServerRequest>
#include <QHttpServerResponse>
#include <cmath>

VideoServer::VideoServer(QObject *parent)
    : QObject(parent)
    , m_server(new QHttpServer(this))
    , m_networkManager(new QNetworkAccessManager(this))
{
    // 创建上传目录
    QDir uploadDir("uploads");
    if (!uploadDir.exists()) {
        uploadDir.mkpath(".");
    }

    // 初始化数据库
    if (!initDatabase()) {
        qWarning() << "数据库启动失败";
    }
}

VideoServer::~VideoServer()
{
    m_database.close();
}

bool VideoServer::startServer(quint16 port)
{
    // 设置路由 - 使用新的API
    m_server->route("/", QHttpServerRequest::Method::Get,
                    [this](const QHttpServerRequest &request) {
                        return handleHealthCheck(request);
                    });

    m_server->route("/api/videos", QHttpServerRequest::Method::Get,
                    [this](const QHttpServerRequest &request) {
                        return handleGetVideos(request);
                    });

    m_server->route("/api/upload/by-path", QHttpServerRequest::Method::Post,
                    [this](const QHttpServerRequest &request) {
                        return handleUploadByPath(request);
                    });

    // 使用新的路由语法
    m_server->route("/api/videos/<arg>",
                    [this](const QString &videoId, const QHttpServerRequest &request) {
                        Q_UNUSED(videoId)
                        return handleGetVideoById(request);
                    });

    m_server->route("/api/videos/search", QHttpServerRequest::Method::Get,
                    [this](const QHttpServerRequest &request) {
                        return handleSearchVideos(request);
                    });

    m_server->route("/api/test-db", QHttpServerRequest::Method::Get,
                    [this](const QHttpServerRequest &request) {
                        return handleTestDB(request);
                    });

    // 创建并配置TCP服务器
    auto tcpServer = new QTcpServer(this);

    // 让TCP服务器开始监听
    if (!tcpServer->listen(QHostAddress::Any, port)) {
        qCritical() << "Failed to start TCP server on port" << port << ":" << tcpServer->errorString();
        delete tcpServer;
        return false;
    }

    // 将HTTP服务器绑定到正在监听的TCP服务器
    if (!m_server->bind(tcpServer)) {
        qCritical() << "Failed to bind HTTP server to TCP server";
        delete tcpServer;
        return false;
    }

    qInfo() << "🚀 Server started: http://localhost:" << tcpServer->serverPort();
    return true;
}

bool VideoServer::initDatabase()
{
    m_database = QSqlDatabase::addDatabase("QMYSQL");
    m_database.setHostName("cq-cdb-nffeyxbr.sql.tencentcdb.com");
    m_database.setPort(21143);
    m_database.setDatabaseName("video_info");
    m_database.setUserName("root");
    m_database.setPassword("12345678n");
    m_database.setConnectOptions("MYSQL_OPT_CONNECT_TIMEOUT=15;MYSQL_OPT_READ_TIMEOUT=15;MYSQL_OPT_WRITE_TIMEOUT=15");

    if (!m_database.open()) {
        qCritical() << "❌ 数据库连接失败:" << m_database.lastError().text();
        return false;
    }

    qInfo() << "✅ 数据库连接成功";
    return initVideoTable();
}

bool VideoServer::initVideoTable()
{
    QString createTableSQL = R"(
        CREATE TABLE IF NOT EXISTS videos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            video_id VARCHAR(255) UNIQUE NOT NULL,
            title VARCHAR(500) NOT NULL,
            description TEXT,
            video_url TEXT NOT NULL,
            cover_url TEXT,
            file_size VARCHAR(50),
            original_filename TEXT,
            cos_key VARCHAR(500),
            duration VARCHAR(20),
            views INT DEFAULT 0,
            upload_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_video_id (video_id),
            INDEX idx_upload_time (upload_time)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    )";

    QSqlQuery query;
    if (!query.exec(createTableSQL)) {
        qCritical() << "❌ 创建数据表失败:" << query.lastError().text();
        return false;
    }

    qInfo() << "✅ 数据表已初始化";
    return true;
}

// 处理健康检查 - 返回 QHttpServerResponse
QHttpServerResponse VideoServer::handleHealthCheck(const QHttpServerRequest &request)
{
    Q_UNUSED(request)

    QJsonObject response{
        {"message", "视频上传服务运行正常"},
        {"timestamp", QDateTime::currentDateTime().toString(Qt::ISODate)}
    };

    return QHttpServerResponse(QJsonDocument(response).toJson(), "application/json");
}

// 处理获取视频列表 - 返回 QHttpServerResponse
QHttpServerResponse VideoServer::handleGetVideos(const QHttpServerRequest &request)
{
    Q_UNUSED(request)
    qInfo() << "📋 Getting video list";

    try {
        auto videos = getVideosFromDatabase();

        if (!videos.isEmpty()) {
            qInfo() << "✅ 成功从数据库中获取" << videos.size() << "个视频";

            QJsonArray videoArray;
            for (const auto &video : videos) {
                videoArray.append(video.toJson());
            }

            QJsonObject response{
                {"code", 0},
                {"message", "获取成功"},
                {"data", videoArray}
            };

            // ✅ 正确的返回方式
            QJsonDocument doc(response);
            return QHttpServerResponse("application/json", doc.toJson());
        }
    } catch (const std::exception &e) {
            qCritical() << "❌ 获取视频列表失败:" << e.what();

            QJsonObject response{
                {"code", 1},
                {"message", QString("获取失败: %1").arg(e.what())}
            };

            // ✅ 正确的返回方式
            QJsonDocument doc(response);
            return QHttpServerResponse("application/json", doc.toJson(),
                                       QHttpServerResponse::StatusCode::InternalServerError);
        }
}

// 处理文件路径上传
QHttpServerResponse VideoServer::handleUploadByPath(const QHttpServerRequest &request)
{
    auto body = request.body();
    auto jsonData = parseJsonBody(body);

    if (jsonData.isEmpty()) {
        return QHttpServerResponse(QJsonDocument(QJsonObject{
                                                     {"code", 1},
                                                     {"message", "Invalid JSON data"}
                                                 }).toJson(), "application/json", QHttpServerResponse::StatusCode::BadRequest);
    }

    QString filePath = jsonData["filePath"].toString();
    QString fileName = jsonData["fileName"].toString();
    QString title = jsonData["title"].toString("未命名视频");
    QString description = jsonData["description"].toString("暂无描述");
    QString coverPath = jsonData["coverPath"].toString();

    qInfo() << "📤 通过文件路径上传:" << filePath;
    qInfo() << "📝 标题:" << title;
    qInfo() << "📄 描述:" << description;

    // 检查文件是否存在
    QFile videoFile(filePath);
    if (!videoFile.exists()) {
        return QHttpServerResponse(QJsonDocument(QJsonObject{
                                                     {"code", 1},
                                                     {"message", "视频文件不存在: " + filePath}
                                                 }).toJson(), "application/json", QHttpServerResponse::StatusCode::BadRequest);
    }

    // 检查封面文件是否存在（如果提供了）
    if (!coverPath.isEmpty()) {
        QFile coverFile(coverPath);
        if (!coverFile.exists()) {
            return QHttpServerResponse(QJsonDocument(QJsonObject{
                                                         {"code", 1},
                                                         {"message", "封面文件不存在: " + coverPath}
                                                     }).toJson(), "application/json", QHttpServerResponse::StatusCode::BadRequest);
        }
    }

    qint64 timestamp = QDateTime::currentSecsSinceEpoch();
    QString videoFileKey = QString("videos/%1_%2").arg(timestamp).arg(fileName);
    QString coverFileKey = QString("covers/%1_%2.jpg").arg(timestamp).arg(QFileInfo(filePath).baseName());

    VideoMetadata videoData;
    videoData.videoId = QString("video_%1").arg(timestamp);
    videoData.title = title;
    videoData.description = description;
    videoData.fileSize = formatFileSize(videoFile.size());
    videoData.originalFileName = QFileInfo(filePath).fileName();
    videoData.cosKey = videoFileKey;
    videoData.duration = generateRandomDuration();
    videoData.views = generateRandomViews().toInt();
    videoData.uploadTime = QDateTime::currentDateTime().toString(Qt::ISODate);

    // 先设置临时 URL，等实际上传成功后再更新
    videoData.videoUrl = QString("https://%1.cos.%2.myqcloud.com/%3")
                             .arg(m_cosBucket)
                             .arg(m_cosRegion)
                             .arg(videoFileKey);
    videoData.coverUrl = QString("https://%1.cos.%2.myqcloud.com/%3")
                             .arg(m_cosBucket)
                             .arg(m_cosRegion)
                             .arg(coverFileKey);

    // 1. 先保存到数据库（记录基本信息）
    if (!saveVideoToDatabase(videoData)) {
        return QHttpServerResponse(QJsonDocument(QJsonObject{
                                                     {"code", 1},
                                                     {"message", "上传失败: 无法保存到数据库"}
                                                 }).toJson(), "application/json", QHttpServerResponse::StatusCode::InternalServerError);
    }

    qInfo() << "✅ 成功保存数据至数据库";

    // 2. 异步上传到 COS
    bool videoUploadStarted = uploadToCOS(videoFileKey, filePath, videoFile.size());

    if (!videoUploadStarted) {
        qCritical() << "❌ 视频文件上传启动失败";
        // 可以考虑删除数据库中的记录
    }

    // 3. 如果有封面，上传封面
    if (!coverPath.isEmpty()) {
        QFile coverFile(coverPath);
        if (coverFile.exists()) {
            bool coverUploadStarted = uploadToCOS(coverFileKey, coverPath, coverFile.size());
            if (!coverUploadStarted) {
                qWarning() << "⚠️ 封面文件上传启动失败";
            }
        }
    }

    // 4. 立即返回成功响应，让用户知道上传已开始
    QJsonObject response{
        {"code", 0},
        {"message", "上传已开始，文件正在上传到云端"},
        {"data", videoData.toJson()}
    };

    QJsonDocument doc(response);
    return QHttpServerResponse("application/json", doc.toJson());
}

// 处理搜索视频
QHttpServerResponse VideoServer::handleSearchVideos(const QHttpServerRequest &request)
{
    auto query = request.query();
    QString keyword = query.queryItemValue("keyword");

    if (keyword.isEmpty()) {
        return QHttpServerResponse(QJsonDocument(QJsonObject{
                                                     {"code", 1},
                                                     {"message", "搜索关键词不能为空"}
                                                 }).toJson(), "application/json", QHttpServerResponse::StatusCode::BadRequest);
    }

    qInfo() << "🔍 Searching videos:" << keyword;

    try {
        auto videos = searchVideosByKeyword(keyword);

        QJsonArray videoArray;
        for (const auto &video : videos) {
            videoArray.append(video.toJson());
        }

        QJsonObject response{
            {"code", 0},
            {"message", "搜索成功"},
            {"data", videoArray}
        };

        return QHttpServerResponse(QJsonDocument(response).toJson(), "application/json");

    } catch (const std::exception &e) {
        qCritical() << "❌ Search failed:" << e.what();

        QJsonObject response{
            {"code", 1},
            {"message", QString("搜索失败: %1").arg(e.what())}
        };

        return QHttpServerResponse(QJsonDocument(response).toJson(), "application/json", QHttpServerResponse::StatusCode::InternalServerError);
    }
}

// 处理获取单个视频
QHttpServerResponse VideoServer::handleGetVideoById(const QHttpServerRequest &request)
{
    QString path = request.url().path();
    QString videoId = path.split('/').last();

    auto video = getVideoFromDatabase(videoId);

    if (!video.videoId.isEmpty()) {
        QJsonObject response{
            {"code", 0},
            {"message", "获取成功"},
            {"data", video.toJson()}
        };

        return QHttpServerResponse(QJsonDocument(response).toJson(), "application/json");
    } else {
        return QHttpServerResponse(QJsonDocument(QJsonObject{
                                                     {"code", 1},
                                                     {"message", "视频不存在"}
                                                 }).toJson(), "application/json", QHttpServerResponse::StatusCode::NotFound);
    }
}

// 处理数据库测试
QHttpServerResponse VideoServer::handleTestDB(const QHttpServerRequest &request)
{
    Q_UNUSED(request)
    qInfo() << "🧪 Testing database connection...";

    QSqlQuery testQuery("SELECT 1 as test");
    if (testQuery.lastError().isValid()) {
        QJsonObject response{
            {"code", 1},
            {"message", "数据库连接失败"},
            {"error", testQuery.lastError().text()}
        };

        return QHttpServerResponse(QJsonDocument(response).toJson(), "application/json");
    }

    qInfo() << "✅ Database connection normal";

    QSqlQuery countQuery("SELECT COUNT(*) as count FROM videos");
    int totalCount = 0;
    if (countQuery.next()) {
        totalCount = countQuery.value("count").toInt();
    }

    qInfo() << "📊 Total records in videos table:" << totalCount;

    QJsonObject response{
        {"code", 0},
        {"message", "数据库测试完成"},
        {"data", QJsonObject{
                     {"totalCount", totalCount}
                 }}
    };

    return QHttpServerResponse(QJsonDocument(response).toJson(), "application/json");
}

// 数据库操作实现 (保持不变)
bool VideoServer::saveVideoToDatabase(const VideoMetadata &videoData)
{
    QString sql = R"(
        INSERT INTO videos
        (video_id, title, description, video_url, cover_url, duration, views, file_size, original_filename, cos_key)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
        title = VALUES(title),
        description = VALUES(description),
        cover_url = VALUES(cover_url),
        file_size = VALUES(file_size),
        updated_at = CURRENT_TIMESTAMP
    )";

    QSqlQuery query;
    query.prepare(sql);
    query.addBindValue(videoData.videoId);
    query.addBindValue(videoData.title);
    query.addBindValue(videoData.description);
    query.addBindValue(videoData.videoUrl);
    query.addBindValue(videoData.coverUrl);
    query.addBindValue(videoData.duration);
    query.addBindValue(videoData.views);
    query.addBindValue(videoData.fileSize);
    query.addBindValue(videoData.originalFileName);
    query.addBindValue(videoData.cosKey);

    if (!query.exec()) {
        qCritical() << "❌ Failed to save video to database:" << query.lastError().text();
        return false;
    }

    qInfo() << "✅ Video data saved to database";
    return true;
}

QList<VideoMetadata> VideoServer::getVideosFromDatabase()
{
    QList<VideoMetadata> videos;

    QString sql = R"(
        SELECT
        video_id as videoId,
        title,
        description,
        video_url as videoUrl,
        cover_url as coverUrl,
        duration,
        views,
        file_size as fileSize,
        original_filename as originalFileName,
        cos_key as cosKey,
        upload_time as uploadTime
        FROM videos
        ORDER BY upload_time DESC
    )";

    QSqlQuery query;
    if (!query.exec(sql)) {
        qCritical() << "❌ Failed to get videos from database:" << query.lastError().text();
        return videos;
    }

    while (query.next()) {
        VideoMetadata video;
        video.videoId = query.value("videoId").toString();
        video.title = query.value("title").toString();
        video.description = query.value("description").toString();
        video.videoUrl = query.value("videoUrl").toString();
        video.coverUrl = query.value("coverUrl").toString();
        video.duration = query.value("duration").toString();
        video.views = query.value("views").toInt();
        video.fileSize = query.value("fileSize").toString();
        video.originalFileName = query.value("originalFileName").toString();
        video.cosKey = query.value("cosKey").toString();
        video.uploadTime = query.value("uploadTime").toString();

        videos.append(video);
    }

    qInfo() << "✅ Retrieved" << videos.size() << "videos from database";
    return videos;
}

VideoMetadata VideoServer::getVideoFromDatabase(const QString &videoId)
{
    VideoMetadata video;

    QString sql = R"(
        SELECT
        video_id as videoId,
        title,
        description,
        video_url as videoUrl,
        cover_url as coverUrl,
        duration,
        views,
        file_size as fileSize,
        original_filename as originalFileName,
        cos_key as cosKey,
        upload_time as uploadTime
        FROM videos
        WHERE video_id = ?
    )";

    QSqlQuery query;
    query.prepare(sql);
    query.addBindValue(videoId);

    if (query.exec() && query.next()) {
        video.videoId = query.value("videoId").toString();
        video.title = query.value("title").toString();
        video.description = query.value("description").toString();
        video.videoUrl = query.value("videoUrl").toString();
        video.coverUrl = query.value("coverUrl").toString();
        video.duration = query.value("duration").toString();
        video.views = query.value("views").toInt();
        video.fileSize = query.value("fileSize").toString();
        video.originalFileName = query.value("originalFileName").toString();
        video.cosKey = query.value("cosKey").toString();
        video.uploadTime = query.value("uploadTime").toString();
    }

    return video;
}

QList<VideoMetadata> VideoServer::searchVideosByKeyword(const QString &keyword)
{
    QList<VideoMetadata> videos;

    QString sql = R"(
        SELECT
        video_id as videoId,
        title,
        description,
        video_url as videoUrl,
        cover_url as coverUrl,
        duration,
        views,
        file_size as fileSize,
        original_filename as originalFileName,
        cos_key as cosKey,
        upload_time as uploadTime
        FROM videos
        WHERE title LIKE ?
        ORDER BY upload_time DESC
    )";

    QSqlQuery query;
    query.prepare(sql);
    query.addBindValue("%" + keyword + "%");

    if (!query.exec()) {
        qCritical() << "❌ Search videos failed:" << query.lastError().text();
        return videos;
    }

    while (query.next()) {
        VideoMetadata video;
        video.videoId = query.value("videoId").toString();
        video.title = query.value("title").toString();
        video.description = query.value("description").toString();
        video.videoUrl = query.value("videoUrl").toString();
        video.coverUrl = query.value("coverUrl").toString();
        video.duration = query.value("duration").toString();
        video.views = query.value("views").toInt();
        video.fileSize = query.value("fileSize").toString();
        video.originalFileName = query.value("originalFileName").toString();
        video.cosKey = query.value("cosKey").toString();
        video.uploadTime = query.value("uploadTime").toString();

        videos.append(video);
    }

    qInfo() << "✅ Found" << videos.size() << "matching videos";
    return videos;
}

// 辅助函数
QString VideoServer::generateRandomDuration()
{
    int minutes = QRandomGenerator::global()->bounded(10) + 1;
    int seconds = QRandomGenerator::global()->bounded(60);
    return QString("%1:%2").arg(minutes, 2, 10, QLatin1Char('0'))
        .arg(seconds, 2, 10, QLatin1Char('0'));
}

QString VideoServer::generateRandomViews()
{
    int views = QRandomGenerator::global()->bounded(100000) + 1000;
    return QString::number(views);
}

QString VideoServer::formatFileSize(qint64 bytes)
{
    if (bytes == 0) return "0 B";
    constexpr double k = 1024;
    const QStringList sizes = {"B", "KB", "MB", "GB"};
    int i = std::floor(std::log(bytes) / std::log(k));
    return QString("%1 %2").arg(bytes / std::pow(k, i), 0, 'f', 2).arg(sizes[i]);
}

QJsonObject VideoServer::parseJsonBody(const QByteArray &body)
{
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(body, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON parse error:" << parseError.errorString();
        return QJsonObject();
    }

    return doc.object();
}

// COS 上传实现
bool VideoServer::uploadToCOS(const QString &fileKey, const QString &filePath, qint64 fileSize)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        qCritical() << "❌ 无法打开文件:" << filePath << file.errorString();
        return false;
    }

    QByteArray fileData = file.readAll();
    file.close();

    // 构造 COS 上传 URL
    QString url = QString("https://%1.cos.%2.myqcloud.com/%3")
                      .arg(m_cosBucket)
                      .arg(m_cosRegion)
                      .arg(fileKey);

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setRawHeader("Authorization", generateCOSAuthorization("PUT", fileKey).toUtf8());
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
    request.setHeader(QNetworkRequest::ContentLengthHeader, fileData.size());

    QNetworkReply *reply = m_networkManager->put(request, fileData);

    // 连接信号来跟踪上传进度
    connect(reply, &QNetworkReply::uploadProgress, [fileKey](qint64 bytesSent, qint64 bytesTotal) {
        if (bytesTotal > 0) {
            int percent = static_cast<int>((bytesSent * 100) / bytesTotal);
            qDebug() << "📊" << fileKey << "上传进度:" << percent << "%";
        }
    });

    // 存储回复对象以便后续处理
    reply->setProperty("fileKey", fileKey);
    reply->setProperty("filePath", filePath);

    return true;
}

#include <QCryptographicHash>
#include <QMessageAuthenticationCode>
#include <QUrl>

QString VideoServer::generateCOSAuthorization(const QString &method, const QString &key)
{
    // 简单版本的签名实现
    QDateTime currentTime = QDateTime::currentDateTime();
    qint64 startTimestamp = currentTime.toSecsSinceEpoch();
    qint64 endTimestamp = startTimestamp + 3600; // 1小时有效期

    QString keyTime = QString("%1;%2").arg(startTimestamp).arg(endTimestamp);

    // 生成签名密钥
    QMessageAuthenticationCode signKey(QCryptographicHash::Sha1);
    signKey.setKey(m_cosSecretKey.toUtf8());
    signKey.addData(keyTime.toUtf8());
    QByteArray signKeyHex = signKey.result().toHex();

    // 生成 HTTP 参数字符串
    QString httpString = QString("%1\n/%2\n\n\n").arg(method.toLower()).arg(key);

    // 生成字符串签名
    QCryptographicHash stringToSignHash(QCryptographicHash::Sha1);
    stringToSignHash.addData(httpString.toUtf8());
    QString stringToSignHex = stringToSignHash.result().toHex();

    QString stringToSign = QString("sha1\n%1\n%2\n").arg(keyTime).arg(stringToSignHex);

    // 生成最终签名
    QMessageAuthenticationCode signatureCode(QCryptographicHash::Sha1);
    signatureCode.setKey(signKeyHex);
    signatureCode.addData(stringToSign.toUtf8());
    QString signature = signatureCode.result().toHex();

    return QString("q-sign-algorithm=sha1&q-ak=%1&q-sign-time=%2&q-key-time=%3&q-header-list=&q-url-param-list=&q-signature=%4")
        .arg(m_cosSecretId)
        .arg(keyTime)
        .arg(keyTime)
        .arg(signature);
}

// 处理 COS 上传完成
void VideoServer::handleCOSUploadFinished(QNetworkReply *reply, const QString &fileKey,
                                          const VideoMetadata &videoData, bool isCover)
{
    if (reply->error() == QNetworkReply::NoError) {
        qInfo() << "✅" << fileKey << "上传到 COS 成功";

        // 检查是否所有文件都上传完成
        // 这里可以添加逻辑来跟踪视频和封面的上传状态
    } else {
        qCritical() << "❌" << fileKey << "上传到 COS 失败:" << reply->errorString();
    }

    reply->deleteLater();
}
