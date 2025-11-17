#pragma once

#include <QObject>
#include "videomanager.h"

class EventController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(VideoManager* videoManager READ videoManager CONSTANT)

public:
    explicit EventController(QObject *parent = nullptr);

    VideoManager* videoManager() const { return m_videoManager; }

private:
    VideoManager* m_videoManager;
};
