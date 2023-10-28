cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMSIMDJSONExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)
CPMAddPackage("gh:simdjson/simdjson@3.5.0")

# ---- Executable ----

add_executable(CPMSIMDJSONExample main.cpp)
target_compile_features(CPMSIMDJSONExample PRIVATE cxx_std_17)
target_link_libraries(CPMSIMDJSONExample simdjson::simdjson)
