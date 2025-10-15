#pragma once
#include <QString>
// #include <QList>
#include <QMap>
#include <QSqlDatabase>
#include "user.h"

class DatabaseUser
{
public:
    // 单例访问方法
    static DatabaseUser *instance();
    static void destroy();
    DatabaseUser();
    ~DatabaseUser();

    // 用于账号检测与管理
    // bool Contains(const QString &account) { return m_users.contains(account); };
    bool AddNetizen(User *user);
    bool RemoveNetizen(const QString &account);
    // User *GetNetizen(const QString &account) { return m_users[account]; };
    // QList<User *> GetAllNetizen() { return m_users.values(); };

    // 数据管理
    bool loadFromDatabase();
    bool saveToDatabase();
    bool initDatabase();

private:
    // 单例访问指针
    static DatabaseUser *m_instance;
    // 数据库连接
    QSqlDatabase m_db;
    // 缓存管理
    QMap<QString, User *> m_users; // 记录所有账号
};
