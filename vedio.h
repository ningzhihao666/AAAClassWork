#pragma once

#include <chrono>
#include <QString>
#include <QDateTime>
#include "comment.h"

class Vedio : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString videoId READ videoId WRITE setId NOTIFY idChanged FINAL)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString author READ author WRITE setAuthor NOTIFY authorChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString uploadDate READ uploadDate WRITE setUploadDate NOTIFY uploadDateChanged)
    Q_PROPERTY(int viewCount READ viewCount WRITE setViewCount NOTIFY viewCountChanged)
    Q_PROPERTY(int likeCount READ likeCount WRITE setLikeCount NOTIFY likeCountChanged)
    Q_PROPERTY(int coinCount READ coinCount WRITE setCoinCount NOTIFY coinCountChanged)
    Q_PROPERTY(int collectionCount READ collectionCount WRITE setCollectionCount NOTIFY collectionCountChanged)
    Q_PROPERTY(bool downloaded READ downloaded WRITE setDownloaded NOTIFY downloadedChanged)
    Q_PROPERTY(int forwardCount READ forwardCount WRITE setForwardCount NOTIFY forwardCountChanged)
    Q_PROPERTY(int bulletCount READ bulletCount WRITE setBulletCount NOTIFY bulletCountChanged)
    Q_PROPERTY(QString videoUrl READ videoUrl WRITE setVideoUrl NOTIFY videoUrlChanged)
    Q_PROPERTY(QString coverUrl READ coverUrl WRITE setCoverUrl NOTIFY coverUrlChanged)
    Q_PROPERTY(int followerCount READ followerCount WRITE setFollower NOTIFY followerChanged)
    Q_PROPERTY(int commitCount READ commitCount WRITE setCommitCount NOTIFY commitChanged)
    Q_PROPERTY(QString headUrl READ headUrl WRITE setHeadUrl NOTIFY headUrlChanged)

    Q_PROPERTY(QList<QObject*> comments READ comments NOTIFY commentsChanged)   //评论列表属性

public:
    explicit Vedio(QObject *parent = nullptr);
    explicit Vedio(const QString &title, const QString &author, QObject *parent = nullptr);

    static QString generateUniqueId();  //生产唯一id

    QString videoId() const { return m_id;}
    void setId(const QString &id)
    {
        if (m_id != id) {
            m_id = id;
            emit idChanged();
        }
    }

    int followerCount() const {return m_followerCount;}
    void setFollower(int follower)
    {
        if (m_followerCount != follower) {
            m_followerCount = follower;
            emit followerChanged();
        }
    }

    QString title() const { return m_title;}
    void setTitle(const QString &title) {
        if (m_title != title) {
            m_title = title;
            emit titleChanged();
        }
    }

    QString author() const {return m_author;}
    void setAuthor(const QString &author) {
        if (m_author != author) {
            m_author = author;
            emit authorChanged();
        }
    }

    QString description() const {return m_description;}
    void setDescription(const QString &description) {
        if (m_description != description) {
            m_description = description;
            emit descriptionChanged();
        }
    }

    QString uploadDate() const {return m_uploadDate;}
    void setUploadDate(const QString &date) {
        if (m_uploadDate != date) {
            m_uploadDate = date;
            emit uploadDateChanged();
        }
    }

    int viewCount() const {return m_viewCount;}
    void setViewCount(int count) {
        if (m_viewCount != count) {
            m_viewCount = count;
            emit viewCountChanged();
        }
    }

    int likeCount() const {return m_likeCount;}
    void setLikeCount(int count) {
        if (m_likeCount != count) {
            m_likeCount = count;
            emit likeCountChanged();
        }
    }

    int coinCount() const {return m_coinCount;}
    void setCoinCount(int count) {
        if (m_coinCount != count) {
            m_coinCount = count;
            emit coinCountChanged();
        }
    }

    int collectionCount() const {return m_collectionCount;}
    void setCollectionCount(int count) {
        if (m_collectionCount != count) {
            m_collectionCount = count;
            emit collectionCountChanged();
        }
    }

    bool downloaded() const  {return m_downloaded;}
    void setDownloaded(bool downloaded) {
        if (m_downloaded != downloaded) {
            m_downloaded = downloaded;
            emit downloadedChanged();
        }
    }

    int forwardCount() const {return m_forwardCount;}
    void setForwardCount(int count) {
        if (m_forwardCount != count) {
            m_forwardCount = count;
            emit forwardCountChanged();
        }
    }

    int bulletCount() const  {return m_bulletCount;}
    void setBulletCount(int count) {
        if (m_bulletCount != count) {
            m_bulletCount = count;
            emit bulletCountChanged();
        }
    }

    QString videoUrl() const { return m_videoUrl; }
    void setVideoUrl(const QString &url) {
        if (m_videoUrl != url) {
            m_videoUrl = url;
            emit videoUrlChanged();
        }
    }

    QString coverUrl() const { return m_coverUrl; }
    void setCoverUrl(const QString &url) {
        if (m_coverUrl != url) {
            m_coverUrl = url;
            emit coverUrlChanged();
        }
    }

    int commitCount() const {return m_commitCount;}
    void setCommitCount(int commitCount)
    {
        if (m_commitCount != commitCount) {
            m_commitCount = commitCount;
            emit commitChanged();
        }
    }

    QString headUrl() const {return m_headUrl;}
    void setHeadUrl(const QString &url)
    {
        if (m_headUrl != url) {
            m_headUrl = url;
            emit headUrlChanged();
        }
    }

    QList<QObject*> comments() const { return m_comments; }
    Q_INVOKABLE void addComment(const QString &userName, const QString &content);
    Q_INVOKABLE void addReply(const QString &parentCommentId, const QString &userName, const QString &content);
    Q_INVOKABLE Comment* getCommentById(const QString &commentId);

    int changeViews(int currentViews);

    int changeLikes(int currentLikes);

    int changCoin(int currentCoin);

    int changeCollect(int currentCollect);

    bool downLoad();

    int changeforward(int currentForward);

signals:
    void idChanged();
    void titleChanged();
    void authorChanged();
    void descriptionChanged();
    void uploadDateChanged();
    void viewCountChanged();
    void likeCountChanged();
    void coinCountChanged();
    void collectionCountChanged();
    void downloadedChanged();
    void forwardCountChanged();
    void bulletCountChanged();
    void videoUrlChanged();
    void coverUrlChanged();
    void followerChanged();
    void commitChanged();
    void headUrlChanged();
    void commentsChanged();
    void commentAdded(Comment* newComment);
    void replyAdded(const QString &parentCommentId, Comment* newReply);

private:
    QString m_id = "";                //视频唯一id
    QString m_title = "空标题";             //标题
    QString m_author = "空名字";            //up主名字
    QString m_description ="这个人很懒，什么描述都没有";       //描述
    QString m_uploadDate;      //上传时间
    int m_viewCount = 0;         //播放量
    int m_likeCount = 0;         //点赞数
    int m_coinCount = 0;         //硬币数量
    int m_collectionCount = 0;   //收藏数量
    bool m_downloaded = false;   //缓存
    int m_forwardCount = 0;      //转发数量
    int m_bulletCount = 0;       //弹幕数量
    int m_followerCount = 0;     //粉丝数
    int m_commitCount = 0;       //评论数量

    QString m_videoUrl; //视频url
    QString m_coverUrl; //封面url
    QString m_headUrl;  //头像url

    QList<QObject*> m_comments;
    QHash<QString, Comment*> m_commentMap; // 用于快速查找评论

};
