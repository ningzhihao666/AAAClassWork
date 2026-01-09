#ifndef VIDEOSUPLOADER_H
#define VIDEOSUPLOADER_H

#include <QObject>
#include <QProcess>
#include <QString>
#include <QVariantMap>
#include <QJsonObject>
#include <QJsonDocument>

class VideoUploader : public QObject
{
    Q_OBJECT

public:
    explicit VideoUploader(QObject* parent = nullptr);

    // 上传视频
    Q_INVOKABLE void uploadVideo(const QString& videoPath,
                                 const QString& title,
                                 const QString& description,
                                 const QString& coverPath = "");

    // 取消上传
    Q_INVOKABLE void cancelUpload();

signals:
    // 上传进度
    void uploadProgress(int percent, const QString& message);

    // 上传完成
    void uploadFinished(const QString& videoUrl,
                        const QString& coverUrl,
                        const QString& identifier);

    // 上传错误
    void uploadError(const QString& error);

    // 上传状态
    void uploadStatus(const QString& status);

private slots:
    void onNodeOutput();
    void onNodeError();
    void onNodeFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    QProcess* m_process;
    QString m_scriptPath;
    QString m_currentVideoPath;
    QString m_currentCoverPath;
    QString m_currentTitle;
    QString m_currentDescription;

    // 解析Node.js输出
    void parseOutput(const QString& output);
    void parseResult(const QJsonObject& result);
    void parseProgress(const QString& line);

    // 工具函数
    QString findScriptPath();
    QJsonObject extractJsonFromOutput(const QString& output);
};

#endif // VIDEOSUPLOADER_H
