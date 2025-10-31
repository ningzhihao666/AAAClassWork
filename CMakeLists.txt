cmake_minimum_required(VERSION 4.1.1)

project(bili VERSION 0.1 LANGUAGES CXX)

# 设置C++标准，确保与Qt6兼容（Qt6需要C++17或更高）
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
set(CMAKE_CXX_MODULE_STD ON)

# 查找Qt6包
find_package(Qt6 REQUIRED COMPONENTS Quick Network Multimedia)
find_package(Qt6 REQUIRED COMPONENTS Quick Sql)

# Qt标准项目设置
qt_standard_project_setup(REQUIRES 6.9)

# 1. 首先创建可执行文件目标
qt_add_executable(appbili)

# 2. 然后正确配置QML模块，将所有资源集中声明
qt_add_qml_module(appbili
    URI bili
    VERSION 1.0
    SOURCES main.cpp  # 主要的C++源文件
    # 将所有QML文件列在一个QML_FILES参数下
    QML_FILES
        Main.qml
        MainPage.qml
        FrameLessWindow.qml
        Mine.qml
        VedioType.qml
        ToolBars.qml
        PersonInfo.qml
        Moments.qml

        # Setting_Page/SettingsPage.qml
        # Setting_Page/AboutSettings.qml
        # Setting_Page/CacheSettings.qml
        # Setting_Page/DownloadSettings.qml
        # Setting_Page/GamepadSettings.qml
        # Setting_Page/GeneralSettings.qml
        # Setting_Page/PlaySettings.qml
        # Setting_Page/PushSettings.qml
        # Setting_Page/SectionDivider.qml
        # Setting_Page/ShortcutKey.qml

        Send_videos/Video.qml
        Send_videos/VideoLode.qml
        Login/LoginDialog.qml
        Login/LoginPage.qml
        Video_Playback/NetworkManager.qml
        Video_Playback/Vedio.qml
        Video_Playback/VedioList.qml

    # 将所有资源文件（.qrc）列在一个RESOURCES参数下
    RESOURCES
        Img.qrc
        images.qrc
        QML_FILES Commit.qml

        QML_FILES DamuSystem.qml
        QML_FILES Message_Page.qml
SOURCES userinfo.h userinfo.cpp user.h user.cpp databaseuser.h databaseuser.cpp
QML_FILES db.js

RESOURCES a站需求文档.odt
QML_FILES SettingsPage.qml
QML_FILES AboutSettings.qml
QML_FILES CacheSettings.qml
QML_FILES DownloadSettings.qml
QML_FILES GamepadSettings.qml
QML_FILES GeneralSettings.qml
QML_FILES PlaySettings.qml
QML_FILES PushSettings.qml
QML_FILES SectionDivider.qml
QML_FILES ShortcutKey.qml
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
