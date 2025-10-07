#pragma once

#include <qobject.h>
class User : public QObject
{
    Q_OBJECT
public:
    explicit User(QObject *parent = nullptr);

signals:
};
