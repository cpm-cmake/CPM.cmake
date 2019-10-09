cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleCereal)

# ---- Options ----

option(ENABLE_TEST_COVERAGE "Enable test coverage" OFF)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME cereal
  VERSION 1.2.2
  GITHUB_REPOSITORY USCiLab/cereal
  OPTIONS
    "SKIP_PORTABILITY_TEST ON"
    "JUST_INSTALL_CEREAL ON"
)

# ---- Create binary ----

add_executable(CPMExampleCereal main.cpp)
target_link_libraries(CPMExampleCereal cereal )
set_target_properties(CPMExampleCereal PROPERTIES CXX_STANDARD 17)

# ---- Add code coverage ----

if (${ENABLE_TEST_COVERAGE})
  set_target_properties(CPMExampleCereal PROPERTIES CXX_STANDARD 17 COMPILE_FLAGS "-O0 -g -fprofile-arcs -ftest-coverage --coverage")
  target_link_options(CPMExampleCereal PUBLIC "--coverage")
endif()
