cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# ---- Options ----

option(ENABLE_TEST_COVERAGE "Enable test coverage" OFF)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME fibonacci
  GIT_REPOSITORY https://github.com/TheLartians/Fibonacci.git
  VERSION 1.0
)

CPMAddPackage(
  NAME doctest
  GITHUB_REPOSITORY onqtam/doctest
  GIT_TAG 2.3.2
)

# ---- Create binary ----

add_executable(CPMExampleDoctest main.cpp)
target_link_libraries(CPMExampleDoctest fibonacci doctest)
set_target_properties(CPMExampleDoctest PROPERTIES CXX_STANDARD 17 COMPILE_FLAGS "-Wall -pedantic -Wextra -Werror")

# ---- Enable testing ----

ENABLE_TESTING() 
ADD_TEST(CPMExampleDoctest CPMExampleDoctest)

# ---- Add code coverage ----

if (${ENABLE_TEST_COVERAGE})
  set_target_properties(CPMExampleDoctest PROPERTIES CXX_STANDARD 17 COMPILE_FLAGS "-O0 -g -fprofile-arcs -ftest-coverage --coverage")
  target_link_options(CPMExampleDoctest PUBLIC "--coverage")
endif()
