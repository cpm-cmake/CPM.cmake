cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleDoctest)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage("gh:cpm-cmake/testpack-fibonacci@2.0")
CPMAddPackage("gh:onqtam/doctest#2.4.5")

# ---- Create binary ----

add_executable(CPMExampleDoctest main.cpp)
target_link_libraries(CPMExampleDoctest fibonacci doctest)
target_compile_features(CPMExampleDoctest PRIVATE cxx_std_17)

# ---- Enable testing ----

enable_testing()
add_test(CPMExampleDoctest CPMExampleDoctest)
