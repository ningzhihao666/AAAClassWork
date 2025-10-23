#pragma once

#include <QObject>
#include <QString>
#include <QList>

class VideoManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QObject *> videoList READ videoList NOTIFY videoListChanged)

public:
    explicit VideoManager(QObject *parent = nullptr);
    ~VideoManager();

    QList<QObject *> videoList() const;

    Q_INVOKABLE void playVideo(int index); //播放视频
    // Q_INVOKABLE void refreshVideoList();   //未实现

signals:
    void videoListChanged();
    void requestPlayVideo(const QUrl &videoUrl);

private:
    void initializeVideoList();
    QList<QObject *> m_videoList;
};
