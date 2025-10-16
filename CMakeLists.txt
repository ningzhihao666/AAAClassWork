cmake_minimum_required(VERSION 3.9)  # Qt6 推荐至少 3.16

project(bili VERSION 0.1 LANGUAGES CXX)

# 设置C++标准，确保与Qt6兼容（Qt6需要C++17或更高）
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找Qt6包
find_package(Qt6 REQUIRED COMPONENTS Quick)

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
        VedioList.qml
        ToolBars.qml
        PersonInfo.qml
        Vedio.qml
        Moments.qml
    # 将所有资源文件（.qrc）列在一个RESOURCES参数下
    RESOURCES
        Img.qrc
        images.qrc
        QML_FILES Commit.qml
        QML_FILES DamuSystem.qml
)

# 链接必要的Qt模块
target_link_libraries(appbili PRIVATE Qt6::Quick)

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
