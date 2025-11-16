// db.js - API 服务器
const mysql = require('mysql');
const http = require('http');
const url = require('url');
const querystring = require('querystring');

// 数据库管理类
class DatabaseManager {
    constructor() {
        this.connection = null;
        this.isConnected = false;
        this.server = null;
        this.port = 3001;
    }

    // 连接数据库
    connect() {
        var self = this;

        return new Promise(function(resolve, reject) {
            if (self.isConnected) {
                resolve(self.connection);
                return;
            }

            self.connection = mysql.createConnection({
                                                         host: 'cq-cdb-82wznfkj.sql.tencentcdb.com',//云数据库外网地址
                                                         user: 'root',
                                                         password: '12345678n',
                                                         database: 'user',
                                                         port: 22290,
                                                         connectTimeout: 15000,
                                                         timeout: 15000,
                                                         charset: 'utf8mb4'
                                                     });

            self.connection.connect(function(error) {
                if (error) {
                    console.error('❌ 数据库连接失败:', error);
                    self.isConnected = false;
                    reject(error);
                    return;
                }
                console.log('✅ 数据库连接成功!');
                self.isConnected = true;
                resolve(self.connection);
            });
        });
    }

    // 创建表
    createTables() {
        var self = this;

        // 异步操作
        return new Promise(function(resolve, reject) {
            self.connect().then(function() {
                var createTableSQL = `
                CREATE TABLE IF NOT EXISTS users (
                account VARCHAR(255) PRIMARY KEY,
                nickname TEXT,
                password TEXT,
                headportrait TEXT,
                sign TEXT,
                level TEXT,
                followingCount TEXT,
                fansCount TEXT,
                likes TEXT,
                isPremiunMembership BOOLEAN DEFAULT FALSE,
                online BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                )
                `;

                // 新增：历史记录表
                var createHistoryTableSQL = `
                CREATE TABLE IF NOT EXISTS history (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_account VARCHAR(255),
                video_id VARCHAR(255),
                video_title TEXT,
                video_cover TEXT,
                video_duration INT,
                watch_time INT DEFAULT 0,
                last_watch_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_account) REFERENCES users(account) ON DELETE CASCADE,
                INDEX idx_user_account (user_account),
                INDEX idx_last_watch_time (last_watch_time)
                )
                `;

                // 新增：收藏表
                var createFavoritesTableSQL = `
                CREATE TABLE IF NOT EXISTS favorites (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_account VARCHAR(255),
                video_id VARCHAR(255),
                video_title TEXT,
                video_cover TEXT,
                video_duration INT,
                collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                folder_id INT DEFAULT 0 COMMENT '收藏夹ID，0为默认收藏夹',
                FOREIGN KEY (user_account) REFERENCES users(account) ON DELETE CASCADE,
                INDEX idx_user_account (user_account),
                INDEX idx_folder_id (folder_id),
                UNIQUE KEY unique_user_video (user_account, video_id, folder_id)
                )
                `;


                //function(error, results)查询之后执行
                self.connection.query(createTableSQL, function(error, results) {
                    if (error) {
                        reject(error);
                        return;
                    }
                    console.log('✅ users表创建/检查完成');

                    self.connection.query(createHistoryTableSQL, function(error, results) {
                        if (error) {
                            reject(error);
                            return;
                        }
                        console.log('✅ history表创建/检查完成');

                        self.connection.query(createFavoritesTableSQL, function(error, results) {
                            if (error) {
                                reject(error);
                                return;
                            }
                            console.log('✅ favorites表创建/检查完成');
                            resolve(true);
                        });
                    });
                    // resolve(true);
                });
            }).catch(function(error) {  //于捕获self.connect().then(...)这个Promise链中可能出现的错误。
                reject(error);
            });
        });
    }

    // 执行查询
    query(sql, params) {  //sql：要执行的SQL语句。params:SQL语句中的参数(可选)
        var self = this;

        return new Promise(function(resolve, reject) {
            if (!self.isConnected) {
                reject(new Error('数据库未连接'));
                return;
            }

            self.connection.query(sql, params, function(error, results) {
                if (error) {
                    reject(error);
                    return;
                }
                resolve(results);
            });
        });
    }

    // API 处理方法
    handleApiRequest(method, path, body) {
        var self = this;

        return new Promise(function(resolve) {
            // 健康检查
            if (path === '/api/health' && method === 'GET') {
                resolve({
                            status: 200,
                            data: {
                                status: 'ok',
                                database: self.isConnected ? 'connected' : 'disconnected',
                                timestamp: new Date().toISOString()  //当前时间戳
                            }
                        });
                return;
            }

            // 初始化数据库
            if (path === '/api/init-database' && method === 'POST') {  // 检查请求路径是否为数据库初始化端点
                self.createTables().then(function() {
                    resolve({
                                status: 200,
                                data: { success: true, message: '数据库初始化成功' }
                            });
                }).catch(function(error) {
                    resolve({
                                status: 500,
                                data: { success: false, error: error.message }
                            });
                });
                return;
            }

            // 获取所有用户
            if (path === '/api/users' && method === 'GET') {
                self.query('SELECT * FROM users').then(function(users) {
                    resolve({
                                status: 200,
                                data: { success: true, data: users }
                            });
                }).catch(function(error) {
                    resolve({
                                status: 500,
                                data: { success: false, error: error.message }
                            });
                });
                return;
            }

            // 根据账号获取用户
            if (path.startsWith('/api/users/') && method === 'GET') {
                var account = path.split('/')[3];  //从 URL 路径中提取用户账号，从/之前开始的为0
                self.query('SELECT * FROM users WHERE account = ?', [account]).then(function(users) {
                    if (users.length > 0) {
                        resolve({
                                    status: 200,
                                    data: { success: true, data: users[0] }
                                });
                    } else {
                        resolve({
                                    status: 404,
                                    data: { success: false, error: '用户不存在' }
                                });
                    }
                }).catch(function(error) {
                    resolve({
                                status: 500,
                                data: { success: false, error: error.message }
                            });
                });
                return;
            }

            // 添加用户
            if (path === '/api/users' && method === 'POST') {
                var account = body.account;   // 从请求体中获取账号
                var nickname = body.nickname;
                var password = body.password;
                var sign = body.sign || '';
                var level = body.level || '1';
                var followingCount = body.followingCount || '0';
                var fansCount = body.fansCount || '0';
                var likes = body.likes || '0';
                var isPremiunMembership = body.isPremiunMembership || false;

                if (!account || !nickname || !password) {// 必要参数
                    resolve({
                                status: 400,
                                data: { success: false, error: '缺少必要参数' }
                            });
                    return;
                }

                var sql = `
                INSERT INTO users (account, nickname, password, sign, level, followingCount, fansCount, likes, isPremiunMembership, online)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                `;

                //调用封装的 query 方法执行插入操作
                self.query(sql, [
                               account, nickname, password, sign, level,
                               followingCount, fansCount, likes, isPremiunMembership, false
                           ]).then(function(result) {
                               resolve({
                                           status: 200,
                                           data: { success: true, data: { id: result.insertId, account: account } }
                                       });
                           }).catch(function(error) {
                               resolve({
                                           status: 500,
                                           data: { success: false, error: error.message }
                                       });
                           });
                return;
            }

            // 更新用户
            if (path.startsWith('/api/users/') && method === 'PUT') {
                var account = path.split('/')[3];
                var nickname = body.nickname;
                var sign = body.sign;
                var level = body.level;
                var followingCount = body.followingCount;
                var fansCount = body.fansCount;
                var likes = body.likes;
                var isPremiunMembership = body.isPremiunMembership;

                var sql = `
                UPDATE users
                SET nickname = ?, sign = ?, level = ?, followingCount = ?, fansCount = ?, likes = ?, isPremiunMembership = ?
                WHERE account = ?
                `;

                self.query(sql, [
                               nickname, sign, level, followingCount, fansCount, likes, isPremiunMembership, account
                           ]).then(function(result) {
                               resolve({
                                           status: 200,
                                           data: { success: true, data: { affectedRows: result.affectedRows } }
                                       });
                           }).catch(function(error) {
                               resolve({
                                           status: 500,
                                           data: { success: false, error: error.message }
                                       });
                           });
                return;
            }

            // 删除用户
            if (path.startsWith('/api/users/') && method === 'DELETE') {
                var account = path.split('/')[3];
                self.query('DELETE FROM users WHERE account = ?', [account]).then(function(result) {
                    resolve({
                                status: 200,
                                data: { success: true, message: '用户删除成功' }
                            });
                }).catch(function(error) {
                    resolve({
                                status: 500,
                                data: { success: false, error: error.message }
                            });
                });
                return;
            }

            // ==================== 新增：历史记录相关 API ====================

            // 新增：获取用户历史记录
            if (path === '/api/history' && method === 'GET') {
                var user_account = parsedUrl.query.user_account;
                var page = parseInt(parsedUrl.query.page) || 1;
                var limit = parseInt(parsedUrl.query.limit) || 20;
                var offset = (page - 1) * limit;

                if (!user_account) {
                    resolve({
                                status: 400,
                                data: { success: false, error: '缺少用户账号参数' }
                            });
                    return;
                }

                var sql = `
                SELECT * FROM history
                WHERE user_account = ?
                ORDER BY last_watch_time DESC
                LIMIT ? OFFSET ?
                `;

                self.query(sql, [user_account, limit, offset]).then(function(history) {
                    resolve({
                                status: 200,
                                data: { success: true, data: history }
                            });
                }).catch(function(error) {
                    resolve({
                                status: 500,
                                data: { success: false, error: error.message }
                            });
                });
                return;
            }

            // 新增：添加历史记录
            if (path === '/api/history' && method === 'POST') {
                var user_account = body.user_account;
                var video_id = body.video_id;
                var video_title = body.video_title;
                var video_cover = body.video_cover;
                var video_duration = body.video_duration;
                var watch_time = body.watch_time || 0;

                if (!user_account || !video_id) {
                    resolve({
                                status: 400,
                                data: { success: false, error: '缺少必要参数' }
                            });
                    return;
                }

                // 使用 ON DUPLICATE KEY UPDATE 来更新已存在的记录
                var sql = `
                INSERT INTO history (user_account, video_id, video_title, video_cover, video_duration, watch_time, last_watch_time)
                VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
                ON DUPLICATE KEY UPDATE
                video_title = VALUES(video_title),
                video_cover = VALUES(video_cover),
                video_duration = VALUES(video_duration),
                watch_time = VALUES(watch_time),
                last_watch_time = CURRENT_TIMESTAMP
                `;

                self.query(sql, [user_account, video_id, video_title, video_cover, video_duration, watch_time])
                .then(function(result) {
                    resolve({
                                status: 200,
                                data: { success: true, message: '历史记录添加成功' }
                            });
                }).catch(function(error) {
                    resolve({
                                status: 500,
                                data: { success: false, error: error.message }
                            });
                });
                return;
            }

            // 新增：清空用户历史记录
            if (path === '/api/history/clear' && method === 'POST') {
                var user_account = body.user_account;

                if (!user_account) {
                    resolve({
                                status: 400,
                                data: { success: false, error: '缺少用户账号参数' }
                            });
                    return;
                }

                self.query('DELETE FROM history WHERE user_account = ?', [user_account])
                .then(function(result) {
                    resolve({
                                status: 200,
                                data: { success: true, message: '历史记录清空成功' }
                            });
                }).catch(function(error) {
                    resolve({
                                status: 500,
                                data: { success: false, error: error.message }
                            });
                });
                return;
            }

            // ==================== 新增：收藏相关 API ====================

            // 新增：获取用户收藏
            if (path === '/api/favorites' && method === 'GET') {
                var user_account = parsedUrl.query.user_account;
                var folder_id = parsedUrl.query.folder_id || 0;
                var page = parseInt(parsedUrl.query.page) || 1;
                var limit = parseInt(parsedUrl.query.limit) || 20;
                var offset = (page - 1) * limit;

                if (!user_account) {
                    resolve({
                                status: 400,
                                data: { success: false, error: '缺少用户账号参数' }
                            });
                    return;
                }

                var sql = `
                SELECT * FROM favorites
                WHERE user_account = ? AND folder_id = ?
                ORDER BY collected_at DESC
                LIMIT ? OFFSET ?
                `;

                self.query(sql, [user_account, folder_id, limit, offset]).then(function(favorites) {
                    resolve({
                                status: 200,
                                data: { success: true, data: favorites }
                            });
                }).catch(function(error) {
                    resolve({
                                status: 500,
                                data: { success: false, error: error.message }
                            });
                });
                return;
            }

            // 新增：添加收藏
            if (path === '/api/favorites' && method === 'POST') {
                var user_account = body.user_account;
                var video_id = body.video_id;
                var video_title = body.video_title;
                var video_cover = body.video_cover;
                var video_duration = body.video_duration;
                var folder_id = body.folder_id || 0;

                if (!user_account || !video_id) {
                    resolve({
                                status: 400,
                                data: { success: false, error: '缺少必要参数' }
                            });
                    return;
                }

                var sql = `
                INSERT INTO favorites (user_account, video_id, video_title, video_cover, video_duration, folder_id)
                VALUES (?, ?, ?, ?, ?, ?)
                `;

                self.query(sql, [user_account, video_id, video_title, video_cover, video_duration, folder_id])
                .then(function(result) {
                    resolve({
                                status: 200,
                                data: { success: true, message: '收藏成功' }
                            });
                }).catch(function(error) {
                    // 如果是重复收藏，返回特定错误信息
                    if (error.code === 'ER_DUP_ENTRY') {
                        resolve({
                                    status: 400,
                                    data: { success: false, error: '该视频已收藏' }
                                });
                    } else {
                        resolve({
                                    status: 500,
                                    data: { success: false, error: error.message }
                                });
                    }
                });
                return;
            }

            // 新增：取消收藏
            if (path === '/api/favorites' && method === 'DELETE') {
                var user_account = body.user_account;
                var video_id = body.video_id;
                var folder_id = body.folder_id || 0;

                if (!user_account || !video_id) {
                    resolve({
                                status: 400,
                                data: { success: false, error: '缺少必要参数' }
                            });
                    return;
                }

                self.query('DELETE FROM favorites WHERE user_account = ? AND video_id = ? AND folder_id = ?',
                           [user_account, video_id, folder_id])
                .then(function(result) {
                    if (result.affectedRows > 0) {
                        resolve({
                                    status: 200,
                                    data: { success: true, message: '取消收藏成功' }
                                });
                    } else {
                        resolve({
                                    status: 404,
                                    data: { success: false, error: '收藏记录不存在' }
                                });
                    }
                }).catch(function(error) {
                    resolve({
                                status: 500,
                                data: { success: false, error: error.message }
                            });
                });
                return;
            }

            // 新增：检查是否已收藏
            if (path === '/api/favorites/check' && method === 'GET') {
                var user_account = parsedUrl.query.user_account;
                var video_id = parsedUrl.query.video_id;
                var folder_id = parsedUrl.query.folder_id || 0;

                if (!user_account || !video_id) {
                    resolve({
                                status: 400,
                                data: { success: false, error: '缺少必要参数' }
                            });
                    return;
                }

                self.query('SELECT id FROM favorites WHERE user_account = ? AND video_id = ? AND folder_id = ?',
                           [user_account, video_id, folder_id])
                .then(function(results) {
                    resolve({
                                status: 200,
                                data: { success: true, is_favorited: results.length > 0 }
                            });
                }).catch(function(error) {
                    resolve({
                                status: 500,
                                data: { success: false, error: error.message }
                            });
                });
                return;
            }

            // 未找到路由
            resolve({
                        status: 404,
                        data: { success: false, error: '接口不存在' }
                    });
        });
    }

    // 启动 API 服务器
    startApiServer() {
        var self = this;

        this.server = http.createServer(function(req, res) {
            // 设置 CORS 头部
            res.setHeader('Access-Control-Allow-Origin', '*');
            res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
            res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

            // 处理预检请求
            if (req.method === 'OPTIONS') {
                res.writeHead(200);
                res.end();
                return;
            }

            var parsedUrl = url.parse(req.url, true);
            var path = parsedUrl.pathname;
            var method = req.method;

            var body = '';
            req.on('data', function(chunk) {
                body += chunk.toString();
            });

            req.on('end', function() {
                var requestBody = {};
                if (body) {
                    try {
                        requestBody = JSON.parse(body);
                    } catch (e) {
                        // 如果不是 JSON，尝试解析为查询字符串
                        requestBody = querystring.parse(body);
                    }
                }

                self.handleApiRequest(method, path, requestBody).then(function(response) {
                    res.writeHead(response.status, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify(response.data));
                });
            });
        });

        this.server.listen(this.port, function(error) {
            if (error) {
                console.error('❌ 启动 API 服务器失败:', error);
                return;
            }
            console.log('🚀 API 服务器运行在 http://localhost:' + self.port);
        });
    }

    // 停止 API 服务器
    stopApiServer() {
        var self = this;

        if (this.server) {
            this.server.close(function() {
                console.log('🔴 API 服务器已停止');
            });
        }
    }

    // 初始化并启动服务
    initialize() {
        var self = this;

        self.connect().then(function() {
            return self.createTables();
        }).then(function() {
            self.startApiServer();
            console.log('✅ 数据库和 API 服务器初始化完成');
        }).catch(function(error) {
            console.error('❌ 初始化失败:', error);
        });
    }
}

// 创建单例实例
var dbManager = new DatabaseManager();

// 如果直接运行此文件，则启动服务
if (require.main === module) {
    dbManager.initialize();
}

// 关闭服务器
process.on('SIGINT', function() {
    console.log('\n🛑 正在关闭服务器...');
    dbManager.stopApiServer();
    if (dbManager.connection) {
        dbManager.connection.end();
    }
    process.exit(0);
});

module.exports = dbManager;
