#include "videoitem.h"

VideoItem::VideoItem(const QString &videoPath)
{
    m_videoUrl = "https://video-1380504831.cos.ap-guangzhou.myqcloud.com/" + videoPath;
}
