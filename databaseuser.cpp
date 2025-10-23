// databaseuser.cpp - 实现 API 客户端功能
#include <QDateTime>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include "databaseuser.h"

DatabaseUser *DatabaseUser::m_instance = nullptr;

DatabaseUser *DatabaseUser::instance()
{
    if (!m_instance) {
        m_instance = new DatabaseUser();
    }
    return m_instance;
}

void DatabaseUser::destroy()
{
    if (m_instance) {
        delete m_instance;
        m_instance = nullptr;
    }
}

DatabaseUser::DatabaseUser() : QObject()
{
    m_networkManager = new QNetworkAccessManager(this);
}

DatabaseUser::~DatabaseUser()
{
    /*if (m_db.isOpen()) {
        m_db.close();
    }
    delete m_networkManager;*/
}

bool DatabaseUser::initDatabase()
{
    // 检查 API 服务器是否可用
    if (!checkServerHealth()) {
        qWarning() << "❌ API 服务器未就绪，请先运行: node db.js";
        return false;
    }

    // 通过 API 初始化数据库
    QJsonObject response = apiRequest("POST", "/init-database");
    if (response.contains("success") && response["success"].toBool()) {
        qDebug() << "✅ 数据库初始化完成（通过 API）";
        return true;
    } else {
        qWarning() << "❌ 数据库初始化失败";
        return false;
    }
}

// 缓存到QMap<QString, User *> m_users;
bool DatabaseUser::loadFromDatabase()
{
    QJsonObject response = apiRequest("GET", "/users");

    if (!response.contains("success") || !response["success"].toBool()) {
        qWarning() << "❌ 加载用户数据失败";
        return false;
    }

    // 清空当前内存缓存
    qDeleteAll(m_users);
    m_users.clear();

    QJsonArray usersArray = response["data"].toArray();
    int loadedCount = 0;

    for (const QJsonValue &value : usersArray) {
        QJsonObject userJson = value.toObject();
        User *user = jsonToUser(userJson);
        if (user) {
            m_users.insert(user->getAccount(), user);
            loadedCount++;
        }
    }

    qDebug() << "✅ 从 API 加载了" << loadedCount << "个用户";
    return true;
}

User* DatabaseUser::getUser(const QString &account)
{
    return m_users.value(account, nullptr);
}

//添加用户信息到users表中
bool DatabaseUser::AddNetizen(User *user)
{
    if (!user || m_users.contains(user->getAccount())) {
        qWarning() << "⚠️ 用户已存在或用户对象为空";
        return false;
    }

    QJsonObject userData;
    userData["account"] = user->getAccount();
    userData["nickname"] = user->getNickname();
    userData["password"] = user->getPassword();
    userData["sign"] = user->getSign();
    userData["level"] = user->getLevel();
    userData["followingCount"] = user->getFollowingCount();
    userData["fansCount"] = user->getFansCount();
    userData["likes"] = user->getLikes();
    userData["isPremiunMembership"] = user->isPremiunMembership();

    QJsonObject response = apiRequest("POST", "/users", userData);

    if (response.contains("success") && response["success"].toBool()) {
        m_users.insert(user->getAccount(), user);
        qDebug() << "✅ 用户" << user->getNickname() << "(" << user->getAccount() << ") 添加成功";
        return true;
    } else {
        qWarning() << "❌ 添加用户失败:"
                   << (response.contains("error") ? response["error"].toString() : "未知错误");
        return false;
    }
}

//从users表删除用户信息
bool DatabaseUser::RemoveNetizen(const QString &account)
{
    if (!m_users.contains(account)) {
        qWarning() << "⚠️ 用户不存在:" << account;
        return false;
    }

    QJsonObject response = apiRequest("DELETE", "/users/" + account);

    if (response.contains("success") && response["success"].toBool()) {
        User *user = m_users.take(account);
        delete user;
        qDebug() << "✅ 用户" << account << "删除成功";
        return true;
    } else {
        qWarning() << "❌ 删除用户失败:" << account;
        return false;
    }
}

// API 客户端实现
bool DatabaseUser::checkServerHealth()
{
    QJsonObject response = apiRequest("GET", "/health");
    return response.contains("status") && response["status"].toString() == "ok";
}

QJsonObject DatabaseUser::apiRequest(const QString &method, const QString &endpoint, const QJsonObject &data)  //mesthod：HTTP 方法（GET、POST、PUT、DELETE）。endpoint：API端点路径。data：要发送的 JSON 数据。
{
    QUrl url(m_apiBaseUrl + endpoint); //m_apiBaseUrl： http://localhost:3000/api;  endpoint：/api/health
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply *reply = nullptr;

    if (method == "GET") {
        reply = m_networkManager->get(request); // 发送请求，不包含数据体（健康检查）
    } else if (method == "POST") {
        reply = m_networkManager->post(request, QJsonDocument(data).toJson()); // 将 JSON 数据转换为字节数组并发送（创建用户）
    } else if (method == "PUT") {
        reply = m_networkManager->put(request, QJsonDocument(data).toJson()); //（更新用户）
    } else if (method == "DELETE") {
        reply = m_networkManager->deleteResource(request);// （删除用户）
    } else {
        qWarning() << "❌ 不支持的 HTTP 方法:" << method;
        return QJsonObject();
    }

    QByteArray responseData = waitForReply(reply);
    reply->deleteLater();

    if (responseData.isEmpty()) {
        return QJsonObject();
    }

    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    return doc.object();
}

QByteArray DatabaseUser::waitForReply(QNetworkReply *reply, int timeout)
{
    QEventLoop loop;
    QTimer timer;

    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);

    timer.start(timeout);
    loop.exec();

    if (!timer.isActive()) {
        qWarning() << "❌ 请求超时";
        reply->abort();
        return QByteArray();
    }

    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << "❌ 网络错误:" << reply->errorString();
        return QByteArray();
    }

    return reply->readAll();
}

// 将QJsonObject对象转化成user类
User* DatabaseUser::jsonToUser(const QJsonObject &json)
{
    if (json.isEmpty()) {
        return nullptr;
    }

    QString account = json["account"].toString();
    QString nickname = json["nickname"].toString();
    QString password = json["password"].toString();

    User *user = new User(nickname, account, password);
    user->setSign(json["sign"].toString());
    user->setHeadportrait(json["headportrait"].toString());
    user->setLevel(json["level"].toString());
    user->setFollowingCount(json["followingCount"].toString());
    user->setFansCount(json["fansCount"].toString());
    user->setLikes(json["likes"].toString());
    user->setIsPremiunMembership(json["isPremiunMembership"].toBool());

    return user;
}



