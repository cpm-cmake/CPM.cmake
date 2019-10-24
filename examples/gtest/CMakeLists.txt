cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleGtest)

# ---- Options ----

option(ENABLE_TEST_COVERAGE "Enable test coverage" OFF)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME fibonacci
  GIT_REPOSITORY https://github.com/TheLartians/Fibonacci.git
  VERSION 2.0
)

CPMFindPackage(
  NAME googletest
  GITHUB_REPOSITORY google/googletest
  GIT_TAG release-1.8.1
  VERSION 1.8.1
  OPTIONS
      "INSTALL_GTEST OFF"
      "gtest_force_shared_crt ON"
)

# ---- Create binary ----

add_executable(CPMExampleGtest main.cpp)
target_link_libraries(CPMExampleGtest fibonacci gtest gtest_main gmock)
set_target_properties(CPMExampleGtest PROPERTIES CXX_STANDARD 17)

# ---- Enable testing ----

enable_testing() 
add_test(CPMExampleGtest CPMExampleGtest)

# ---- Add code coverage ----

if (${ENABLE_TEST_COVERAGE})
  set_target_properties(CPMExampleGtest PROPERTIES CXX_STANDARD 17 COMPILE_FLAGS "-O0 -g -fprofile-arcs -ftest-coverage --coverage")
  target_link_options(CPMExampleGtest PUBLIC "--coverage")
endif()
