cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

# add dependencies
include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME LarsParser
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  VERSION 1.7
)

# add executable
add_executable(calculator main.cpp)
set_target_properties(calculator PROPERTIES CXX_STANDARD 17)
target_link_libraries(calculator LarsParser)
