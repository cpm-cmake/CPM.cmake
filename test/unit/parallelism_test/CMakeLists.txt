# A cut-down version of the Full CMakeLists Example in the README.md

cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
project(CPMParallelismTest)

set(CPM_SOURCE_CACHE ${CMAKE_CURRENT_LIST_DIR}/_deps)
include(${CPM_PATH}/CPM.cmake)

CPMAddPackage("gh:fmtlib/fmt#7.1.3")
