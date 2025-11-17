#pragma once

#include <QObject>
#include "videomanager.h"

class EventController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(VideoManager* videoManager READ videoManager CONSTANT)

public:
    // 单例访问方法
    static EventController* instance();

    // 初始化方法（可选，用于显式初始化）
    static void init(QObject* parent = nullptr);

    // 销毁方法（可选，用于提前清理）
    static void destroy();

    VideoManager* videoManager() const { return m_videoManager; }

private:
    explicit EventController(QObject *parent = nullptr);

    static EventController* m_instance;
    VideoManager* m_videoManager;
};
