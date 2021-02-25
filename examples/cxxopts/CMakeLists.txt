cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleCXXOpts)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage("gh:jarro2783/cxxopts@2.2.0")

# ---- Create binary ----

add_executable(CPMExampleCXXOpts main.cpp)
target_link_libraries(CPMExampleCXXOpts cxxopts)
target_compile_features(CPMExampleCXXOpts PRIVATE cxx_std_17)
