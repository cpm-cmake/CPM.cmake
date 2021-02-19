cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMlinenoiseExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage("gh:antirez/linenoise#1.0")

if(linenoise_ADDED)
  add_library(linenoise ${linenoise_SOURCE_DIR}/linenoise.c)
  target_include_directories(linenoise SYSTEM PUBLIC ${linenoise_SOURCE_DIR})
endif()

# ---- Executable ----

add_executable(CPMlinenoiseExample main.cpp)
target_compile_features(CPMlinenoiseExample PRIVATE cxx_std_17)
target_link_libraries(CPMlinenoiseExample linenoise)
