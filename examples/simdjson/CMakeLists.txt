cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMSIMDJSONExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)
CPMAddPackage("gh:simdjson/simdjson@4.6.3")

# ---- Executable ----

add_executable(CPMSIMDJSONExample main.cpp)
target_link_libraries(CPMSIMDJSONExample simdjson::simdjson)
