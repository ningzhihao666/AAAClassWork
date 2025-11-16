cmake_minimum_required(VERSION 3.9)

project(bili VERSION 0.1 LANGUAGES CXX)

# 设置C++标准，确保与Qt6兼容（Qt6需要C++17或更高）
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
set(CMAKE_CXX_MODULE_STD ON)

# 查找Qt6包
find_package(Qt6 REQUIRED COMPONENTS Quick Network Multimedia)
find_package(Qt6 REQUIRED COMPONENTS Quick Sql)

# Qt标准项目设置
qt_standard_project_setup(REQUIRES 6.9)


qt_add_executable(appbili)


qt_add_qml_module(appbili
    URI bili
    VERSION 1.0
    SOURCES main.cpp  # 主要的C++源文件
    # 将所有QML文件列在一个QML_FILES参数下
    QML_FILES
        Main.qml
        MainPage.qml
        FrameLessWindow.qml



        Tools_Left/PersonInfo.qml



        Send_videos/VideolodeFunction.qml
        Send_videos/VideoLode.qml

        Login/LoginPage.qml
        Video_Playback/NetworkManager.qml
        Video_Playback/Video.qml


    # 将所有资源文件（.qrc）列在一个RESOURCES参数下
    RESOURCES
        Img.qrc
        images.qrc
        QML_FILES Commit.qml

        QML_FILES DamuSystem.qml
        QML_FILES Tools_Left/Message_Page.qml
SOURCES userinfo.h userinfo.cpp user.h user.cpp databaseuser.h databaseuser.cpp
QML_FILES db.js

RESOURCES a站需求文档.odt
QML_FILES Settings/SettingsPage.qml
QML_FILES Settings/AboutSettings.qml
QML_FILES Settings/CacheSettings.qml
QML_FILES Settings/DownloadSettings.qml
QML_FILES Settings/GamepadSettings.qml
QML_FILES Settings/GeneralSettings.qml
QML_FILES Settings/PlaySettings.qml
QML_FILES Settings/PushSettings.qml
QML_FILES Settings/SectionDivider.qml
QML_FILES Settings/ShortcutKey.qml
QML_FILES Tools_Left/My.qml
QML_FILES Tools_Left/Dynamic.qml
SOURCES clienthandler.cpp
SOURCES clientmessagehandler.h
SOURCES clientmessagehandler.cpp
SOURCES clienthandler.h
RESOURCES lll.qrc
)

# 链接必要的Qt模块
target_link_libraries(appbili
    PRIVATE
        Qt6::Quick
        Qt6::Network
        Qt6::Multimedia
        Qt6::Sql
)

# 设置平台相关的属性
set_target_properties(appbili PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# 安装规则（可选，根据需要调整）
include(GNUInstallDirs)
install(TARGETS appbili
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)


# 忽略 JavaScript 文件的语法检查
set(CMAKE_CXX_CLANG_TIDY "")  # 禁用 clang-tidy
set(CMAKE_CXX_CPPCHECK "")    # 禁用 cppcheck

# 或者针对特定文件
set_source_files_properties(server.js PROPERTIES
    SKIP_AUTOMOC TRUE
    SKIP_AUTOUIC TRUE
    SKIP_AUTORCC TRUE
)
