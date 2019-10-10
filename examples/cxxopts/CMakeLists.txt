cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleCXXOpts)

# ---- Options ----

option(ENABLE_TEST_COVERAGE "Enable test coverage" OFF)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME cxxopts
  GITHUB_REPOSITORY jarro2783/cxxopts
  VERSION 2.2.0
  OPTIONS
    "CXXOPTS_BUILD_EXAMPLES Off"
    "CXXOPTS_BUILD_TESTS Off"
)

# ---- Create binary ----

add_executable(CPMExampleCXXOpts main.cpp)
target_link_libraries(CPMExampleCXXOpts cxxopts)
set_target_properties(CPMExampleCXXOpts PROPERTIES CXX_STANDARD 17 COMPILE_FLAGS "-Wall -pedantic -Wextra -Werror")
