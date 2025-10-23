#include "videomanager.h"
#include <QDebug>
#include <qurl.h>
#include "videoitem.h"

class VideoItem;

VideoManager::VideoManager(QObject *parent)
    : QObject(parent)
{
    initializeVideoList(); //初始化
}

VideoManager::~VideoManager()
{
    qDeleteAll(m_videoList); //删除m_videoList中的所有元素
}

QList<QObject *> VideoManager::videoList() const
{
    return m_videoList;
}

void VideoManager::playVideo(int index)
{
    if (index >= 0 && index < m_videoList.size()) {
        VideoItem *video = static_cast<VideoItem *>(m_videoList.at(index)); //把列表中元素转换为VideoItem
        QUrl videoUrl(video->videoUrl());
        qDebug() << "Playing video:" << videoUrl; //测试
        emit requestPlayVideo(videoUrl);          //发射播放视频信号
    }
}

// void VideoManager::refreshVideoList()
// {
//     qDeleteAll(m_videoList);
//     m_videoList.clear();
//     initializeVideoList();
//     emit videoListChanged();
// } //此功能还没实现 想的是刷新页面

void VideoManager::initializeVideoList()
{
    qDebug() << "init"; //测试
    m_videoList.append(new VideoItem(
        "videos/1761136167962_%E3%80%8A%E8%A1%80%E7%96%91%E3%80%8B%E4%B8%BB%E9%A2%98%E6%9B%B2%E5%81%87%E5%90%8D%"
        "E7%BD%97%E9%A9%AC%E9%9F%B3%E5%AD%97%E5%B9%95%E5%AE%8C%E6%95%B4%E7%89%88-p01-32.mp4"));

    m_videoList.append(
        new VideoItem("videos/1761136151150_%E9%A3%8E%E7%BB%8F%E8%BF%87%E5%94%B1%E7%A6%BB%E5%90%88.mp4"));
}
