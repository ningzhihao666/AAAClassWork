#include "comment.h"
#include <iostream>
#include <random>

namespace domain {

    Comment::Comment()
         : m_time(std::chrono::system_clock::now()) {
    }

    Comment::Comment(const std::string& content, const std::string& userName)
        : m_id(generateId())
        , m_userName(userName)
        , m_time(std::chrono::system_clock::now())
        , m_content(content)
        , m_isReply(false) {
        //对应createRootComment
    }

    Comment::Comment(const std::string& id,
                     const std::string& userName,
                     const std::string& content,
                     bool isReply,
                     const std::string& parentId)
        : m_id(id)
        , m_userName(userName)
        , m_time(std::chrono::system_clock::now())
        , m_content(content)
        , m_isReply(isReply)
        , m_parentId(parentId){
        //对应createReplyComment
    }

    Comment Comment::createRootComment(const std::string& content, const std::string& userName,const std::string& customId)
    {
        if (content.empty() || userName.empty()) {
            throw std::invalid_argument("Content or userName is empty");
        }

        std::string id = customId.empty() ? generateId() : customId;
        return Comment(id, userName, content, false, "");
    }


    Comment Comment::createReplyComment(const std::string& content,
                                        const std::string& userName,
                                        const std::string& parentId,
                                        const std::string& customId)
    {
        if (content.empty() || userName.empty() || parentId.empty()) {
            std::cerr << "创建评论警告：内容、名字或者父id为空！" << std::endl;
            throw std::invalid_argument("Content, userName or parentId is empty");
        }

        std::string id = customId.empty() ? generateId() : customId;
        return Comment(id, userName, content, true, parentId);
    }

    void Comment::addReply(const Comment& reply)
    {
        m_replies.push_back(reply);
    }

    std::string Comment::generateId() {
        static std::random_device rd;
        static std::mt19937 gen(rd());
        static std::uniform_int_distribution<> dis(0, 15);

        const char* hex = "0123456789abcdef";
        std::string id = "comment_";

        for (int i = 0; i < 16; ++i) {
            id += hex[dis(gen)];
        }

        return id;
    }



}
