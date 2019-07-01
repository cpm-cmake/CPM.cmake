cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# ---- Create binary ----

add_executable(CPMExampleBoost main.cpp)
set_target_properties(CPMExampleBoost PROPERTIES CXX_STANDARD 17)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME boost
  GITHUB_REPOSITORY Orphis/boost-cmake
  VERSION 1.67.0
)

target_link_libraries(CPMExampleBoost PRIVATE Boost::system)
