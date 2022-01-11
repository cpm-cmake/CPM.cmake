cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(using-adder)

include("%{cpm_path}")

%{packages}

add_executable(using-adder using-adder.cpp)

target_link_libraries(using-adder adder)
