cmake_minimum_required(VERSION 4.1.1)

#https://github.com/Kitware/CMake/blob/v4.1.1/Help/dev/experimental.rst

set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
set(CMAKE_CXX_MODULE_STD ON)

project(Bilibili VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Network Multimedia HttpServer Sql)

# configure_file(${CMAKE_SOURCE_DIR}/config.ini ${CMAKE_BINARY_DIR}/config.ini COPYONLY)

qt_add_executable(appBilibili)

qt_add_qml_module(appBilibili
    URI Bilibili
    VERSION 1.0
    SOURCES
        main.cpp
        src/domain/video.cpp
        src/domain/video.h

    QML_FILES
        Main.qml
        component/FrameLessWindow.qml
        component/DamuSystem.qml
        qml/Commit.qml
        qml/Video_Playback/Video.qml qml/Video_Playback/NetworkManager.qml
        qml/User_HomePage/User_HomePage.qml
        qml/Tools_Left/PersonInfo.qml
        qml/Tools_Left/My.qml qml/Tools_Left/Message_Page.qml
        qml/Tools_Left/Dynamic.qml
        qml/Settings/AboutSettings.qml qml/Settings/CacheSettings.qml qml/Settings/DownloadSettings.qml
        qml/Settings/GamepadSettings.qml qml/Settings/GeneralSettings.qml qml/Settings/PlaySettings.qml qml/Settings/PushSettings.qml
        qml/Settings/SectionDivider.qml qml/Settings/SettingsPage.qml qml/Settings/ShortcutKey.qml
        qml/Send_Videos/VideoLode.qml qml/Send_Videos/VideolodeFunction.qml
        qml/Login/LoginPage.qml
        component/ModernLoadingIndicator.qml

    SOURCES
        src/domain/videoVO.h
        src/domain/comment.h src/domain/comment.cpp
        src/domain/commentVO.h
        src/component/clientmessagehandler.h src/component/clientmessagehandler.cpp src/component/clienthandler.h src/component/clienthandler.cpp
        src/domain/videorepository.h src/domain/videorepository.cpp
        src/database/videoDatabase.h src/database/videoDatabase.cpp
        src/application/userServerController.cpp src/application/userServerController.h
        src/database/userdatabase.cpp src/database/userdatabase.h
        src/domain/user.cpp src/domain/user.h src/domain/userVO.h
        src/application/videoServerContorller.cpp
        src/application/videoServerContorller.h
        src/presentation/videoController.cpp
        src/presentation/videoController.h
        src/presentation/userController.cpp src/presentation/userController.h
        src/component/simpleuploader.h  src/component/simpleuploader.cpp
        src/domain/videoserver.h
        src/component/videouploader.h src/component/videouploader.cpp
        src/domain/videoserver.cpp
)

target_sources(appBilibili
    PRIVATE
        #math.cpp                   # 实现单元
    PRIVATE FILE_SET cxx_modules TYPE CXX_MODULES  FILES
        #math.cppm                  # 接口单元
)

source_group("QML Files" FILES
    Main.qml
)

target_compile_features(appBilibili PRIVATE cxx_std_23)

target_link_libraries(appBilibili
    PRIVATE
        Qt6::Quick
        Qt6::Network
        Qt6::Multimedia
        Qt6::Sql
        Qt6::HttpServer
)

set_target_properties(appBilibili PROPERTIES
    AUTORCC TRUE                              #  set(CMAKE_AUTORCC ON)
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appBilibili
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS appBilibili
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)


















































# set(CMAKE_CXX_STANDARD_REQUIRED ON) # Globally preventing the fallback behaviour of C++ standard
#qt_add_executable(Bilibili)  //Creates and finalizes an application target of a platform-specific type.
#This command performs the following tasks:
#    1. Create a CMake target of the appropriate type for the target platform.
#    2. Link the target to the Qt::Core library.
#    3. Handle finalization of the CMake target.

# set(CMAKE_CXX_STANDARD_REQUIRED ON) # Globally preventing the fallback behaviour of C++ standard

# qt_standard_project_setup()  #set(CMAKE_AUTOUIC ON)  set(CMAKE_AUTOMOC ON)






# cmake_minimum_required(VERSION 3.16)
#
# project(Bilibili VERSION 0.1 LANGUAGES CXX)
#
# @if !false
# set(CMAKE_AUTOMOC ON)
# @endif
# set(CMAKE_CXX_STANDARD_REQUIRED ON)
#
# find_package(Qt6 REQUIRED COMPONENTS Quick)
#
# @if false
# @if false
# qt_standard_project_setup(REQUIRES 6.10)
# @else
# qt_standard_project_setup()
# @endif
# @endif
#
# qt_add_executable(appBilibili
#     main.cpp
# )
#
# qt_add_qml_module(appBilibili
#     URI Bilibili
#     VERSION 1.0
#     QML_FILES
#         Main.qml
# )
#
# # Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# # If you are developing for iOS or macOS you should consider setting an
# # explicit, fixed bundle identifier manually though.
# set_target_properties(appBilibili PROPERTIES
# #    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appBilibili
#     MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
#     MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
#     MACOSX_BUNDLE TRUE
#     WIN32_EXECUTABLE TRUE
# )
#
# target_link_libraries(appBilibili
#     PRIVATE Qt6::Quick
# )
#
# include(GNUInstallDirs)
# install(TARGETS appBilibili
#     BUNDLE DESTINATION .
#     LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
#     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
# )
