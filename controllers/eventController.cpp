#include "eventController.h"
#include <QCoreApplication>
#include <QDebug>

// 静态成员初始化
EventController* EventController::m_instance = nullptr;

EventController* EventController::instance()
{
    if (!m_instance) {
        qWarning() << "EventController 尚未初始化！请在创建 QApplication 后调用 EventController::init()";
        // 或者可以选择在这里自动初始化（不推荐，因为可能没有合适的 parent）
        // m_instance = new EventController(qApp);
    }
    return m_instance;
}

void EventController::init(QObject* parent)
{
    if (!m_instance) {
        m_instance = new EventController(parent);
        qDebug() << "EventController 初始化完成";
    } else {
        qWarning() << "EventController 已经初始化过了";
    }
}

void EventController::destroy()
{
    if (m_instance) {
        delete m_instance;
        m_instance = nullptr;
        qDebug() << "EventController 已销毁";
    }
}

EventController::EventController(QObject *parent)
    : QObject(parent)
    , m_videoManager(new VideoManager(this))
{
    // 其他初始化代码...
}
