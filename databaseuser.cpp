#include <QDateTime>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
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

    m_db = QSqlDatabase::addDatabase("QMYSQL");
    m_db.setHostName("10.0.0.2:3306");
    m_db.setPort(3306);
    m_db.setDatabaseName("database_userinfo.db");
    m_db.setUserName("root");
    m_db.setPassword("lsy02282725");
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
    if (!m_db.transaction()) {
        qWarning() << "Failed to start transaction:" << m_db.lastError().text();
        return false;
    }

    try {
        // 清空旧的user数据（或者使用UPDATE替代）
        if (!query.exec("TRUNCATE TABLE users")) {
            throw std::runtime_error(query.lastError().text().toStdString());
        }

        // 准备插入语句
        if (!query.prepare("INSERT INTO users (account, nickname, password, headportrait, sign, "
                           "level, followingCount, fansCount, likes, isPermiunMembership, online) "
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")) {
            throw std::runtime_error(query.lastError().text().toStdString());
        }

        // 保存所有用户
        for (auto user : m_users.values()) {
            query.addBindValue(user->getAccount());
            query.addBindValue(user->getNickname());
            // query.addBindValue(user->getPassword());
            // query.addBindValue(user->getAvatarBase64());
            query.addBindValue(user->getSign());
            query.addBindValue(user->getLevel());
            query.addBindValue(user->getFollowingCount());
            query.addBindValue(user->getFansCount());
            query.addBindValue(user->getLikes());
            // query.addBindValue(user->isPremiumMembership);
            // query.addBindValue(user->isOnline);

            if (!query.exec()) {
                throw std::runtime_error(query.lastError().text().toStdString());
            }
        }

        if (!m_db.commit()) {
            throw std::runtime_error("Failed to commit transaction");
        }

        return true;
    } catch (const std::exception &e) {
        m_db.rollback();
        qWarning() << "Save to database failed:" << e.what();
        return false;
    }
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
