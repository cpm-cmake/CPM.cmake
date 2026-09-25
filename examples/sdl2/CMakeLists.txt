cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMSDLExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)
CPMAddPackage("gh:libsdl-org/SDL#release-2.0.16")

# ---- Executable ----

add_executable(CPMSDLExample main.cpp)

target_link_libraries(CPMSDLExample SDL2)
