cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleBoost)

# ---- Create binary ----

add_executable(CPMExampleBoost main.cpp)
set_target_properties(CPMExampleBoost PROPERTIES CXX_STANDARD 17)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMFindPackage(
  NAME Boost
  GITHUB_REPOSITORY Orphis/boost-cmake
  VERSION 1.67.0
  FIND_PACKAGE_ARGUMENTS "COMPONENTS system"
)

target_link_libraries(CPMExampleBoost PRIVATE Boost::system pthread)
