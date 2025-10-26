//视频服务器连接端口

import QtQuick
import QtQml

QtObject {
    id: networkManager

    property string baseUrl: "http://localhost:3000"

    signal requestComplete(bool success, var response)

    function get(endpoint, callback) {
        var xhr = new XMLHttpRequest();
        var fullUrl = baseUrl + endpoint;

        console.log("🌐 发送请求:", fullUrl);

        xhr.onreadystatechange = function() {
            console.log("📡 请求状态:", xhr.readyState, "状态码:", xhr.status);

            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("📋 响应数据:", xhr.responseText);

                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        console.log("✅ API响应成功:", endpoint, response);
                        if (callback) callback(true, response);
                        requestComplete(true, response);
                    } catch (e) {
                        console.error("❌ JSON解析失败:", e);
                        if (callback) callback(false, {message: "数据解析失败"});
                        requestComplete(false, {message: "数据解析失败"});
                    }
                } else {
                    console.error("❌ HTTP请求失败:", xhr.status, xhr.statusText, "URL:", fullUrl);
                    if (callback) callback(false, {message: "网络请求失败: " + xhr.status + " - " + xhr.statusText});
                    requestComplete(false, {message: "网络请求失败: " + xhr.status + " - " + xhr.statusText});
                }
            }
        };

        xhr.onerror = function() {
            console.error("🔌 网络连接错误，请检查:");
            console.error("  1. 服务器是否启动");
            console.error("  2. 网络连接是否正常");
            console.error("  3. URL是否正确:", fullUrl);
            if (callback) callback(false, {message: "网络连接错误"});
            requestComplete(false, {message: "网络连接错误"});
        };

        xhr.open("GET", fullUrl);
        xhr.send();
    }

    function post(endpoint, data, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if (callback) callback(true, response);
                        requestComplete(true, response);
                    } catch (e) {
                        console.error("JSON解析失败:", e);
                        if (callback) callback(false, {message: "数据解析失败"});
                        requestComplete(false, {message: "数据解析失败"});
                    }
                } else {
                    console.error("HTTP请求失败:", xhr.status, xhr.statusText);
                    if (callback) callback(false, {message: "网络请求失败: " + xhr.status});
                    requestComplete(false, {message: "网络请求失败: " + xhr.status});
                }
            }
        };

        xhr.open("POST", baseUrl + endpoint);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(JSON.stringify(data));
    }
}
