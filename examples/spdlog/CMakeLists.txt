cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMSpdlogExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage("gh:gabime/spdlog@1.8.2")

# ---- Executable ----

add_executable(CPMSpdlogExample main.cpp)
target_compile_features(CPMSpdlogExample PRIVATE cxx_std_17)
target_link_libraries(CPMSpdlogExample spdlog)
