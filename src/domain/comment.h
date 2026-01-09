#pragma once
#include <iostream>
#include <chrono>
#include <vector>
#include<memory>
#include "commentVO.h"

namespace domain {

    class Comment
    {
    public:

        explicit Comment();
        explicit Comment(const std::string& content, const std::string& userName);

        const std::string& id() const { return m_id; }

        std::chrono::system_clock::time_point time() const { return m_time; }
        std::string timeToString() const;

        static Comment createRootComment(
            const std::string& content,
            const std::string& userName,
            const std::string& customId = ""
            );

        static Comment createReplyComment(
            const std::string& content,
            const std::string& userName,
            const std::string& parentId,
            const std::string& customId = ""
            );

        void addReply(const Comment& reply);

        bool isReply() const { return m_isReply; }

        const std::vector<Comment>& replies() const { return m_replies; }

        domain::vo::CommentVO toVO() const
        {
            domain::vo::CommentVO vo = {
                                        .id = m_id,
                                        .userName = m_userName,
                                        .time = m_time,
                                        .content = m_content,
                                        .likeCount = m_likeCount,
                                        .unlikeCount = m_unlikeCount,
                                        .isReply = m_isReply,
                                        .parentId = m_parentId
            };

            for (const auto& reply : m_replies) {
                vo.replies.push_back(reply.toVO());
            }
            return vo;
        }

        //点赞和点踩
        void addLike()
        {
            m_likeCount++;
            // std::cout<<"当前点赞数:"<<m_likeCount;
        }
        void addUnlike()
        {
            m_unlikeCount++;
            // std::cout<<"当前点踩数:"<<m_unlikeCount;
        }

    private:
        std::string m_id;                  //评论唯一标识符
        std::string m_userName;            //发表评论用户名
        std::chrono::system_clock::time_point m_time;              //评论时间
        std::string m_content;             //评论内容
        int m_likeCount = 0;           //点赞数量
        int m_unlikeCount = 0;         //点踩数量
        bool m_isReply = false;        //是否为回复
        std::string m_parentId;            //父评论
        std::string m_replyModelId;        //回复id
        std::vector<Comment> m_replies; // 回复列表


        // 私有构造函数
        Comment(const std::string& id,
                const std::string& userName,
                const std::string& content,
                bool isReply = false,
                const std::string& parentId = "");

        static std::string generateId();
    };

}


