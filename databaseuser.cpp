#include <QDateTime>
#include <QSqlQuery>
#include <QSqlError>
#include "databaseuser.h"

// 初始化单例指针
DatabaseUser *DatabaseUser::m_instance = nullptr;

DatabaseUser *DatabaseUser::instance()
{
    if (!m_instance) { m_instance = new DatabaseUser(); }
    return m_instance;
}

void DatabaseUser::destroy()
{
    if (m_instance) {
        delete m_instance;
        m_instance = nullptr;
    }
}

DatabaseUser::DatabaseUser() {}

DatabaseUser::~DatabaseUser()
{
    saveToDatabase();
    // 释放内存
    for (auto it = m_users.begin(); it != m_users.end(); ++it) {
        delete it.value();
    }
}

bool DatabaseUser::initDatabase()
{
    if (m_db.isOpen()) m_db.close();

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName("databse_userinfo.db");

    if (!m_db.open()) {
        qWarning() << "Failed to open database:" << m_db.lastError().text();
        return false;
    }

    QSqlQuery query;

    // 创建users表
    if (!query.exec("CREATE TABLE IF NOT EXISTS users ("
                    "account TEXT PRIMARY KEY,"
                    "nickname TEXT,"
                    "password TEXT,"
                    "headportrait TEXT,"
                    "sign TEXT,"
                    "level TEXT,"
                    "followingCount TEXT,"
                    "fansCount TEXT,"
                    "likes TEXT,"
                    "isPermiunMembership INTEGER,"
                    "online INTEGER)")) {
        qWarning() << "Failed to create users table:" << query.lastError().text();
        return false;
    }

    // 创建friends表
    // if (!query.exec(
    //         "CREATE TABLE IF NOT EXISTS friends ("
    //         "user_account TEXT,"
    //         "friend_account TEXT,"
    //         "PRIMARY KEY (user_account, friend_account))")) {
    //     qWarning() << "Failed to create friends table:" << query.lastError().text();
    //     return false;
    // }

    return true;
}

bool DatabaseUser::loadFromDatabase()
{
    if (!m_db.isOpen() && !m_db.open()) {
        qWarning() << "Database is not open:" << m_db.lastError().text();
        return false;
    }

    QSqlQuery query;

    // 加载所有用户
    if (!query.exec("SELECT account, nickname, password, headportrait, sign, level, followingCount, fansCount, likes "
                    "FROM users")) {
        qWarning() << "Failed to query users:" << query.lastError().text();
        return false;
    }

    while (query.next()) {
        QString account = query.value(0).toString();
        QString nickname = query.value(1).toString();
        QString password = query.value(2).toString();
        QString avatar = query.value(3).toString();
        QString sign = query.value(4).toString();
        QString level = query.value(5).toString();
        QString followingCount = query.value(6).toString();
        QString fansCount = query.value(7).toString();
        QString likes = query.value(8).toString();

        // User *user = new User(nickname, account, password);
        // user->setOnline(false);
        // user->setSign(sign);
        // user->updateAvatar(avatar);

        // m_users.insert(account, user);
    }

    return true;
}

bool DatabaseUser::saveToDatabase()
{
    if (!m_db.isOpen() && !m_db.open()) {
        qWarning() << "Database is not open:" << m_db.lastError().text();
        return false;
    }

    QSqlQuery query;

    // 事务保护
    m_db.transaction();

    // 清空旧的user数据
    if (!query.exec("DELETE FROM users")) {
        qWarning() << "Failed to clear tables:" << query.lastError().text();
        m_db.rollback();
        return false;
    }

    // 保存users
    query.prepare("INSERT INTO users (account, nickname, password, sign, level, followingCount, fansCount, likes ) "
                  "VALUES (?, ?, ?, ?, ?)");
    for (auto user : m_users.values()) {
        // query.addBindValue(user->getAccount());
        // query.addBindValue(user->getNickname());
        // query.addBindValue(user->getPassword());
        // // query.addBindValue(user->getAvatarBase64());
        // query.addBindValue(user->getSign());
        // query.addBindValue(user->getLevel());
        // query.addBindValue(user->getFollowingCount);
        // query.addBindValue(user->getFansCount());
        // query.addBindValue(user->getLikes());

        if (!query.exec()) {
            qWarning() << "Failed to insert user:" << query.lastError().text();
            m_db.rollback();
            return false;
        }
    }

    return m_db.commit();
}

// bool DatabaseUser::AddUser(User *user)
// {
//     // 检测是否存在对应用户
//     if (user && !Contains(user->getAccount())) {
//         m_users.insert(user->getAccount(), user);
//         Logger::Log("Account " + user->getAccount() + " add successfully.");
//         return true;
//     } else {
//         Logger::Error("Account " + user->getAccount() + " already exist.");
//         return false;
//     }
// }

// bool DatabaseUser::RemoveUser(const QString &account)
// {
//     User *toRemove = GetUser(account);
//     m_users.remove(account);
//     delete toRemove;
//     return true;
// }
