#include "videouploader.h"
#include <QProcess>
#include <QFileInfo>
#include <QDebug>
#include <QCoreApplication>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QRegularExpression>

VideoUploader::VideoUploader(QObject* parent)
    : QObject(parent)
    , m_process(new QProcess(this))
    , m_scriptPath(findScriptPath())
{
    qDebug() << "VideoUploader初始化";
    qDebug() << "脚本路径:" << m_scriptPath;

    connect(m_process, &QProcess::readyReadStandardOutput,
            this, &VideoUploader::onNodeOutput);
    connect(m_process, &QProcess::readyReadStandardError,
            this, &VideoUploader::onNodeError);
    connect(m_process, &QProcess::finished,
            this, &VideoUploader::onNodeFinished);
}

QString VideoUploader::findScriptPath()
{
    QStringList possiblePaths = {
        QCoreApplication::applicationDirPath() + "/../../upload.js",
        QCoreApplication::applicationDirPath() + "/upload.js",
        QDir::currentPath() + "/../upload.js",
        QDir::currentPath() + "/upload.js"
    };

    for (const QString& path : possiblePaths) {
        if (QFile::exists(path)) {
            qDebug() << "找到脚本:" << path;
            return path;
        }
    }

    qWarning() << "未找到upload.js脚本";
    return "";
}

void VideoUploader::uploadVideo(const QString& videoPath,
                                const QString& title,
                                const QString& description,
                                const QString& coverPath)
{
    m_currentVideoPath = videoPath;
    m_currentCoverPath = coverPath;
    m_currentTitle = title;
    m_currentDescription = description;

    QFileInfo videoFile(videoPath);
    if (!videoFile.exists()) {
        emit uploadError("视频文件不存在: " + videoPath);
        return;
    }

    if (title.trimmed().isEmpty()) {
        emit uploadError("视频标题不能为空");
        return;
    }

    if (m_scriptPath.isEmpty() || !QFile::exists(m_scriptPath)) {
        emit uploadError("找不到upload.js脚本");
        return;
    }

    qDebug() << "开始上传视频...";
    qDebug() << "视频文件:" << videoPath;
    qDebug() << "封面文件:" << coverPath;
    qDebug() << "标题:" << title;

    emit uploadStatus("开始上传视频...");
    emit uploadProgress(0, "准备上传");

    // 停止之前的进程
    if (m_process->state() != QProcess::NotRunning) {
        m_process->kill();
    }

    // 构建命令
    QStringList arguments = {m_scriptPath};

    if (coverPath.isEmpty()) {
        arguments << "video" << videoPath;
    } else {
        arguments << "both" << videoPath << coverPath;
    }

    qDebug() << "执行命令: node" << arguments;

    // 设置工作目录
    QFileInfo scriptInfo(m_scriptPath);
    m_process->setWorkingDirectory(scriptInfo.absolutePath());

    // 启动Node.js进程
    m_process->start("node", arguments);

    if (!m_process->waitForStarted(5000)) {
        emit uploadError("无法启动Node.js进程");
        return;
    }

    emit uploadStatus("Node.js上传进程已启动");
}

void VideoUploader::cancelUpload()
{
    if (m_process->state() != QProcess::NotRunning) {
        m_process->kill();
        emit uploadStatus("上传已取消");
        emit uploadError("上传被用户取消");
    }
}

void VideoUploader::onNodeOutput()
{
    QString output = QString::fromUtf8(m_process->readAllStandardOutput());
    if (!output.isEmpty()) {
        parseOutput(output);
    }
}

void VideoUploader::onNodeError()
{
    QString error = QString::fromUtf8(m_process->readAllStandardError());
    if (!error.trimmed().isEmpty()) {
        qDebug() << "Node.js错误:" << error;
    }
}

void VideoUploader::onNodeFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    qDebug() << "Node.js进程结束，退出码:" << exitCode;

    if (exitCode != 0 && exitStatus == QProcess::NormalExit) {
        emit uploadError("上传进程异常退出，代码: " + QString::number(exitCode));
    }
}

void VideoUploader::parseOutput(const QString& output)
{
    QStringList lines = output.split('\n', Qt::SkipEmptyParts);
    static QString jsonBuffer;

    for (const QString& line : lines) {
        QString cleanLine = line.trimmed();
        if (cleanLine.isEmpty()) continue;

        qDebug() << "Node.js:" << cleanLine;
        emit uploadStatus(cleanLine);

        // 解析进度
        if (cleanLine.contains("PROGRESS:")) {
            parseProgress(cleanLine);
        }

        // 开始收集JSON
        if (cleanLine.startsWith('{') || cleanLine.startsWith('"')) {
            jsonBuffer = cleanLine;
        }
        // 如果是JSON的一部分但不是第一行
        else if (!jsonBuffer.isEmpty() && (cleanLine.endsWith(',') || cleanLine.endsWith('}') || cleanLine.startsWith('"') || cleanLine.contains(':'))) {
            // 如果这一行是JSON的继续部分，添加到缓冲区
            if (!cleanLine.endsWith('}')) {
                // 移除可能的逗号
                if (cleanLine.endsWith(',')) {
                    cleanLine.chop(1);
                }
            }
            jsonBuffer += cleanLine;
        }

        // 检查是否收集到完整的JSON
        if (!jsonBuffer.isEmpty() && cleanLine.endsWith('}')) {
            // 尝试解析JSON
            qDebug() << "尝试解析JSON:" << jsonBuffer;
            QJsonParseError parseError;
            QJsonDocument doc = QJsonDocument::fromJson(jsonBuffer.toUtf8(), &parseError);

            if (parseError.error == QJsonParseError::NoError && doc.isObject()) {
                QJsonObject result = doc.object();
                qDebug() << "JSON解析成功";
                parseResult(result);
                jsonBuffer.clear();  // 清空缓冲区
            } else {
                // 如果解析失败，尝试清理字符串
                QString cleanedJson = jsonBuffer;
                // 确保以{}包裹
                if (!cleanedJson.startsWith('{')) {
                    int startIndex = cleanedJson.indexOf('{');
                    if (startIndex != -1) {
                        cleanedJson = cleanedJson.mid(startIndex);
                    }
                }
                if (!cleanedJson.endsWith('}')) {
                    int endIndex = cleanedJson.lastIndexOf('}');
                    if (endIndex != -1) {
                        cleanedJson = cleanedJson.left(endIndex + 1);
                    }
                }

                qDebug() << "清理后的JSON:" << cleanedJson;
                QJsonDocument cleanedDoc = QJsonDocument::fromJson(cleanedJson.toUtf8(), &parseError);
                if (parseError.error == QJsonParseError::NoError && cleanedDoc.isObject()) {
                    QJsonObject result = cleanedDoc.object();
                    parseResult(result);
                } else {
                    qDebug() << "JSON解析失败:" << parseError.errorString() << "，在位置:" << parseError.offset;
                    qDebug() << "原始数据:" << jsonBuffer;
                }
                jsonBuffer.clear();
            }
        }
    }
}

QJsonObject VideoUploader::extractJsonFromOutput(const QString& output)
{
    int start = output.indexOf('{');
    int end = output.lastIndexOf('}');

    if (start != -1 && end != -1 && end > start) {
        QString jsonStr = output.mid(start, end - start + 1);
        QJsonDocument doc = QJsonDocument::fromJson(jsonStr.toUtf8());
        if (doc.isObject()) {
            return doc.object();
        }
    }

    return QJsonObject();
}

void VideoUploader::parseResult(const QJsonObject& result)
{
    if (result["success"].toBool()) {
        if (result.contains("video") && result.contains("cover")) {
            // 同时上传视频和封面
            QJsonObject videoObj = result["video"].toObject();
            QJsonObject coverObj = result["cover"].toObject();

            QString videoUrl = videoObj["url"].toString();
            QString coverUrl = coverObj["url"].toString();
            QString identifier = result["identifier"].toString();

            qDebug() << "视频和封面上传完成";
            qDebug() << "标识符:" << identifier;
            qDebug() << "视频URL:" << videoUrl;
            qDebug() << "封面URL:" << coverUrl;

            emit uploadFinished(videoUrl, coverUrl, identifier);
            emit uploadProgress(100, "上传完成");
            emit uploadStatus("✅ 视频和封面上传完成");

        } else if (result.contains("url")) {
            // 只上传视频
            QString videoUrl = result["url"].toString();
            QString identifier = result["identifier"].toString();

            qDebug() << "视频上传完成";
            qDebug() << "标识符:" << identifier;
            qDebug() << "视频URL:" << videoUrl;

            emit uploadFinished(videoUrl, "", identifier);
            emit uploadProgress(100, "上传完成");
            emit uploadStatus("✅ 视频上传完成");
        }
    } else {
        QString error = result["error"].toString();
        if (error.isEmpty()) {
            error = "上传失败";
        }
        emit uploadError(error);
    }
}

void VideoUploader::parseProgress(const QString& line)
{
    QRegularExpression progressRegex("上传进度:\\s*(\\d+)%");
    QRegularExpressionMatch match = progressRegex.match(line);

    if (match.hasMatch()) {
        int percent = match.captured(1).toInt();
        emit uploadProgress(percent, "上传进度: " + QString::number(percent) + "%");
    }
}
