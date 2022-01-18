cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(using-fibadder)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

include("%{cpm_path}")

%{packages}

add_executable(using-fibadder using-fibadder.cpp)

target_link_libraries(using-fibadder fibadder)
