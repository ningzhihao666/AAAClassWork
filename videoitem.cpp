#include "videoitem.h"

VideoItem::VideoItem(const QString &title,
                     const QString &uploader,
                     const QString &views,
                     const QString &likes,
                     const QString &date,
                     const QString &duration,
                     const QString &videoPath)
    : m_title{title}
    , m_date{date}
    , m_views{views}
    , m_likes{likes}
    , m_uploader{uploader}
    , m_duration{duration}
{
    m_videoUrl = "https://video-1380504831.cos.ap-guangzhou.myqcloud.com/" + videoPath;
}
