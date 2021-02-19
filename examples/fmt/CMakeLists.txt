cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMJSONExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage("gh:fmtlib/fmt#7.1.3")

# ---- Executable ----

add_executable(CPMFmtExample main.cpp)
target_compile_features(CPMFmtExample PRIVATE cxx_std_17)
target_link_libraries(CPMFmtExample fmt)
