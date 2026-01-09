#ifndef SIMPLEUPLOADER_H
#define SIMPLEUPLOADER_H

#include <QObject>
#include <QString>
#include <QProcess>

class SimpleUploader : public QObject
{
    Q_OBJECT

public:
    explicit SimpleUploader(QObject* parent = nullptr);

    // 上传文件
    void upload(const QString& filePath);

    // 查找脚本文件
    QString findScriptFile();

signals:
    void progress(const QString& message);
    void finished(const QString& url);
    void error(const QString& error);

private:
    QProcess* m_process;
    QString m_scriptPath;
};

#endif // SIMPLEUPLOADER_H
