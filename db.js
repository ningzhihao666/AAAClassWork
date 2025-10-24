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
        this.port = 3000;
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
                host: 'gz-cdb-dc5b0mxb.sql.tencentcdb.com',//云数据库外网地址
                user: 'root',
                password: 'lsy02282725',
                database: 'userinfo',
                port: 27455,
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

                //function(error, results)查询之后执行
                self.connection.query(createTableSQL, function(error, results) {
                    if (error) {
                        reject(error);
                        return;
                    }
                    console.log('✅ users表创建/检查完成');
                    resolve(true);
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
