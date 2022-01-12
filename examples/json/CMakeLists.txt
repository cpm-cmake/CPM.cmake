cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMJSONExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)
CPMAddPackage("gh:nlohmann/json@3.10.5")

# ---- Executable ----

add_executable(CPMJSONExample main.cpp)
target_compile_features(CPMJSONExample PRIVATE cxx_std_17)
target_link_libraries(CPMJSONExample nlohmann_json::nlohmann_json)
