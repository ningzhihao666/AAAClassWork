#include "eventController.h"

EventController::EventController(QObject *parent)
    : QObject(parent)
    , m_videoManager(new VideoManager(this))
{
}
