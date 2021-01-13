cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMSpdlogExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME spdlog
  GITHUB_REPOSITORY gabime/spdlog
  VERSION 1.7.0
)

# ---- Executable ----

add_executable(CPMSpdlogExample "main.cpp")
set_target_properties(CPMSpdlogExample PROPERTIES CXX_STANDARD 17)
target_link_libraries(CPMSpdlogExample spdlog)
