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
  NAME Catch2
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  VERSION 2.5.0
)

# ---- Create binary ----

add_executable(CPMExampleCatch2 main.cpp)
target_link_libraries(CPMExampleCatch2 fibonacci Catch2)
set_target_properties(CPMExampleCatch2 PROPERTIES CXX_STANDARD 17 COMPILE_FLAGS "-Wall -pedantic -Wextra -Werror")

# ---- Enable testing ----

ENABLE_TESTING() 
ADD_TEST(CPMExampleCatch2 CPMExampleCatch2)

# ---- Add code coverage ----

if (${ENABLE_TEST_COVERAGE})
  set_target_properties(CPMExampleCatch2 PROPERTIES CXX_STANDARD 17 COMPILE_FLAGS "-O0 -g -fprofile-arcs -ftest-coverage --coverage")
  target_link_options(CPMExampleCatch2 PUBLIC "--coverage")
endif()
