cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

project(CPMParserLuaExample)

include(../../cmake/CPM.cmake)

# ---- Dependencies ----

CPMAddPackage(
  NAME Glue
  GIT_REPOSITORY https://github.com/TheLartians/Glue.git
  VERSION 0.8.2
  OPTIONS 
    "GLUE_ENABLE_LUA ON"
    "GLUE_BUILD_LUA ON"
)

CPMAddPackage(
  NAME LarsParser
  GIT_REPOSITORY https://github.com/TheLartians/Parser.git
  VERSION 1.9
  OPTIONS 
    "LARS_PARSER_BUILD_GLUE_EXTENSION ON"
)

# ---- Create binary ----

add_executable(parser-lua main.cpp)
set_target_properties(parser-lua PROPERTIES CXX_STANDARD 17)
target_link_libraries(parser-lua LHC LarsParser Glue)
