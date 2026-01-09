#include "simpleuploader.h"
#include <QProcess>
#include <QFileInfo>
#include <QDebug>
#include <QCoreApplication>
#include <QDir>
#include <QFile>

SimpleUploader::SimpleUploader(QObject* parent)
    : QObject(parent)
    , m_process(new QProcess(this))
{
    qDebug() << "上传器初始化";

    // 尝试多个路径查找脚本
    QStringList possiblePaths = {
        QCoreApplication::applicationDirPath() + "/upload.js",  // 可执行文件目录
        QDir::currentPath() + "/upload.js",  // 当前工作目录
        QCoreApplication::applicationDirPath() + "/../upload.js",  // 可执行文件上一级
        QDir::currentPath() + "/../upload.js",  // 当前工作目录上一级
        "/root/bilibili项目/最新代码修改/Bilibili/upload.js",  // 绝对路径
        "/root/bilibili项目/最新代码修改/Bilibili/build/upload.js"  // 构建目录绝对路径
    };

    qDebug() << "查找upload.js脚本，可能路径:";
    for (int i = 0; i < possiblePaths.size(); ++i) {
        qDebug() << "  " << i+1 << ":" << possiblePaths[i];
        if (QFile::exists(possiblePaths[i])) {
            m_scriptPath = possiblePaths[i];
            qDebug() << "✅ 找到脚本:" << m_scriptPath;
            break;
        }
    }

    if (m_scriptPath.isEmpty()) {
        qDebug() << "❌ 未找到upload.js脚本";
    }

    connect(m_process, &QProcess::readyReadStandardOutput, this, [this]() {
        QString output = QString::fromUtf8(m_process->readAllStandardOutput());
        QStringList lines = output.split('\n', Qt::SkipEmptyParts);

        for (const QString& line : lines) {
            QString cleanLine = line.trimmed();
            if (cleanLine.isEmpty()) continue;

            qDebug() << "Node.js:" << cleanLine;
            emit progress(cleanLine);

            if (cleanLine.contains("文件URL:")) {
                // 提取URL
                int start = cleanLine.indexOf("http");
                if (start != -1) {
                    QString url = cleanLine.mid(start);
                    emit finished(url);
                }
            } else if (cleanLine.contains("上传失败")) {
                emit error(cleanLine);
            }
        }
    });

    connect(m_process, &QProcess::finished, this, [this](int exitCode) {
        if (exitCode != 0) {
            emit error("上传进程异常退出，退出码: " + QString::number(exitCode));
        }
    });
}

QString SimpleUploader::findScriptFile()
{
    // 尝试多个可能的路径
    QStringList possiblePaths = {
        QCoreApplication::applicationDirPath() + "/upload.js",  // 可执行文件目录
        QDir::currentPath() + "/upload.js",  // 当前工作目录
        QCoreApplication::applicationDirPath() + "/../upload.js",  // 可执行文件上一级
        QDir::currentPath() + "/../upload.js",  // 当前工作目录上一级
        "/root/bilibili项目/最新代码修改/Bilibili/upload.js",  // 绝对路径
        "/root/bilibili项目/最新代码修改/Bilibili/build/upload.js"  // 构建目录绝对路径
    };

    for (const QString& path : possiblePaths) {
        if (QFile::exists(path)) {
            qDebug() << "✅ 找到脚本:" << path;
            return path;
        }
    }

    qDebug() << "❌ 未找到upload.js脚本";
    return "";
}

void SimpleUploader::upload(const QString& filePath)
{
    QFileInfo fileInfo(filePath);
    if (!fileInfo.exists()) {
        emit error("文件不存在: " + filePath);
        return;
    }

    qDebug() << "开始上传:" << filePath;

    // 检查Node.js
    QProcess nodeCheck;
    nodeCheck.start("node", QStringList() << "--version");
    if (!nodeCheck.waitForFinished(3000)) {
        emit error("未安装Node.js，请先安装");
        return;
    }

    m_scriptPath = findScriptFile();
    if (m_scriptPath.isEmpty()) {
        emit error("找不到upload.js脚本");
        return;
    }

    QString nodeVersion = QString::fromUtf8(nodeCheck.readAllStandardOutput()).trimmed();
    qDebug() << "Node.js版本:" << nodeVersion;

    // 重新检查脚本路径
    if (m_scriptPath.isEmpty() || !QFile::exists(m_scriptPath)) {
        qDebug() << "重新查找upload.js脚本...";

        // 再次尝试多个路径
        QStringList possiblePaths = {
            QCoreApplication::applicationDirPath() + "/upload.js",  // 可执行文件目录
            QDir::currentPath() + "/upload.js",  // 当前工作目录
            QCoreApplication::applicationDirPath() + "/../upload.js",  // 可执行文件上一级
            QDir::currentPath() + "/../upload.js",  // 当前工作目录上一级
            "/root/bilibili项目/最新代码修改/Bilibili/upload.js",  // 绝对路径
            "/root/bilibili项目/最新代码修改/Bilibili/build/upload.js"  // 构建目录绝对路径
        };

        bool found = false;
        for (int i = 0; i < possiblePaths.size(); ++i) {
            if (QFile::exists(possiblePaths[i])) {
                m_scriptPath = possiblePaths[i];
                qDebug() << "✅ 找到脚本:" << m_scriptPath;
                found = true;
                break;
            }
        }

        if (!found) {
            qDebug() << "❌ 未找到upload.js脚本，检查以下路径:";
            for (int i = 0; i < possiblePaths.size(); ++i) {
                qDebug() << "  " << i+1 << ":" << possiblePaths[i];
            }
            emit error("找不到upload.js脚本");
            return;
        }
    }

    qDebug() << "使用脚本:" << m_scriptPath;

    // 检查文件是否可读
    QFileInfo scriptInfo(m_scriptPath);
    if (!scriptInfo.isReadable()) {
        emit error("脚本文件不可读: " + m_scriptPath);
        return;
    }

    qDebug() << "脚本大小:" << scriptInfo.size() << "字节";

    // 设置工作目录
    m_process->setWorkingDirectory(scriptInfo.absolutePath());
    qDebug() << "工作目录:" << m_process->workingDirectory();

    // 执行上传
    QStringList args = {m_scriptPath, filePath};
    qDebug() << "执行命令: node" << args;

    m_process->start("node", args);

    if (!m_process->waitForStarted(5000)) {
        emit error("无法启动Node.js进程");
        return;
    }

    qDebug() << "Node.js进程已启动";
}
