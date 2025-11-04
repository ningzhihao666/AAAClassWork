cmake_minimum_required(VERSION 3.5)
project(server)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找Qt库
find_package(Qt6 COMPONENTS Core Network REQUIRED)
find_package(Qt6 REQUIRED COMPONENTS Quick Sql)

# 添加可执行文件
add_executable(server
    main.cpp
    serverhandler.cpp
    serverhandler.h
)

# 启用自动MOC（元对象编译器）
set_target_properties(server PROPERTIES
    AUTOMOC ON
)

# 链接Qt库
target_link_libraries(server
    Qt6::Core
    Qt6::Network
    Qt6::Sql
    -static-libstdc++
)


