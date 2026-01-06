#include "comment.h"
#include <iostream>
#include <random>

namespace domain {

    Comment::Comment()
         : m_time(std::chrono::system_clock::now()) {
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

    Comment::Comment(const std::string& content, const std::string& userName)
        : m_id(generateId())
        , m_userName(userName)
        , m_time(std::chrono::system_clock::now())
        , m_content(content)
        , m_isReply(false) {
        //对应createRootComment
    }


    std::unique_ptr<Comment> Comment::createRootComment(
        const std::string& content,
        const std::string& userName) {

        if (content.empty() || userName.empty()) {
            std::cerr << "创建评论警告：内容或者名字为空！" << std::endl;
            return nullptr;
        }

        return std::unique_ptr<Comment>(
            new Comment(content, userName)
            );
    }


    std::unique_ptr<Comment> Comment::createReplyComment(
        const std::string& content,
        const std::string& userName,
        const std::string& parentId) {

        if (content.empty() || userName.empty() || parentId.empty()) {
            std::cerr << "创建评论警告：内容、名字或者父id为空！" << std::endl;
            return nullptr;
        }

        auto comment = std::unique_ptr<Comment>(
            new Comment(generateId(), userName, content, true, parentId)
            );

        return comment;
    }

    void Comment::addReply(std::unique_ptr<Comment> reply)
    {
        if(reply)
        {
            m_replies.push_back(std::move(reply));
        }
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
