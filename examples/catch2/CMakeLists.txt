cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleCatch2)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage("gh:cpm-cmake/testpack-fibonacci@2.0")
CPMAddPackage("gh:catchorg/Catch2@3.4.0")

# ---- Create binary ----

add_executable(CPMExampleCatch2 main.cpp)
target_link_libraries(CPMExampleCatch2 fibonacci Catch2::Catch2WithMain)
target_compile_features(CPMExampleCatch2 PRIVATE cxx_std_17)

# ---- Enable testing ----

enable_testing()
add_test(CPMExampleCatch2 CPMExampleCatch2)
