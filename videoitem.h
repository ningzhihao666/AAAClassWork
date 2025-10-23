//单个的视频类 供VideoManager使用

#pragma once

#include <QObject>
#include <QString>

class VideoItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString title READ title CONSTANT)
    Q_PROPERTY(QString uploader READ uploader CONSTANT)
    Q_PROPERTY(QString views READ views CONSTANT)
    Q_PROPERTY(QString likes READ likes CONSTANT)
    Q_PROPERTY(QString date READ date CONSTANT)
    Q_PROPERTY(QString videoUrl READ videoUrl CONSTANT)

public:
    VideoItem(const QString &title,
              const QString &uploader,
              const QString &views,
              const QString &likes,
              const QString &date,
              const QString &duration,
              const QString &videoPath);

    QString videoUrl() const { return m_videoUrl; }
    QString title() const { return m_title; }
    QString uploader() const { return m_uploader; }
    QString views() const { return m_views; }
    QString likes() const { return m_likes; }
    QString date() const { return m_date; }
    QString duration() const { return m_duration; }

private:
    QString m_videoUrl;
    QString m_title;
    QString m_uploader;
    QString m_views;
    QString m_likes;
    QString m_date;
    QString m_duration;
};
