cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMlinenoiseExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME linenoise
  GIT_TAG 1.0
  GITHUB_REPOSITORY antirez/linenoise
)

if(linenoise_ADDED)
  add_library(linenoise ${linenoise_SOURCE_DIR}/linenoise.c)
  target_include_directories(linenoise PUBLIC ${linenoise_SOURCE_DIR})
endif()

# ---- Executable ----

add_executable(CPMlinenoiseExample "main.cpp")
set_target_properties(CPMlinenoiseExample PROPERTIES CXX_STANDARD 17)
target_link_libraries(CPMlinenoiseExample linenoise)
