#pragma once

#include <QObject>
#include <QString>

class VideoItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString videoUrl READ videoUrl CONSTANT)

public:
    VideoItem(const QString &videoPath);

    QString videoUrl() const { return m_videoUrl; }

private:
    QString m_videoUrl;
};
