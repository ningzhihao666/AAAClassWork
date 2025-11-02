// databaseuser.h - 在现有文件中添加 API 客户端功能
#pragma once
#include <QString>
#include <QMap>
#include <QSqlDatabase>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QEventLoop>
#include <QTimer>
#include "user.h"

class DatabaseUser : public QObject
{
    Q_OBJECT

public:
    // 单例访问方法
    static DatabaseUser *instance();
    static void destroy();
    DatabaseUser();
    ~DatabaseUser();

    // 用于账号检测与管理
    bool AddNetizen(User *user);
    bool RemoveNetizen(const QString &account);

    // 数据管理
    bool loadFromDatabase();
    bool saveToDatabase();
    bool initDatabase();

    // 基本查询功能
    User* getUser(const QString &account);

private:
    // 单例访问指针
    static DatabaseUser *m_instance;

    // 缓存管理
    QMap<QString, User *> m_users;

    // API 客户端功能
    QNetworkAccessManager *m_networkManager;
    QString m_apiBaseUrl = "http://localhost:3001/api";

    // API 请求方法
    bool checkServerHealth();
    QJsonObject apiRequest(const QString &method, const QString &endpoint, const QJsonObject &data = QJsonObject());
    QByteArray waitForReply(QNetworkReply *reply, int timeout = 5000);

    // 辅助方法 将数据库中表的信息加载成user类
    User* jsonToUser(const QJsonObject &json);
};
