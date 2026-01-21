cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMSFMLExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)
CPMAddPackage("gh:SFML/SFML#2.5.1")

# ---- Executable ----

add_executable(CPMSFMLExample main.cpp)
target_compile_features(CPMSFMLExample PRIVATE cxx_std_17)
target_link_libraries(CPMSFMLExample sfml-system sfml-graphics sfml-window sfml-audio)
