cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMYamlExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage("gh:jbeder/yaml-cpp#yaml-cpp-0.6.3@0.6.3")

# ---- Executable ----

add_executable(CPMYamlExample main.cpp)
target_compile_features(CPMYamlExample PRIVATE cxx_std_17)
target_link_libraries(CPMYamlExample yaml-cpp)
