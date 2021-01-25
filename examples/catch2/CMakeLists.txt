cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleCatch2)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME fibonacci
  GITHUB_REPOSITORY TheLartians/Fibonacci
  VERSION 2.0
)

CPMAddPackage(
  NAME Catch2
  GITHUB_REPOSITORY catchorg/Catch2
  VERSION 2.5.0
)

# ---- Create binary ----

add_executable(CPMExampleCatch2 main.cpp)
target_link_libraries(CPMExampleCatch2 fibonacci Catch2)
set_target_properties(CPMExampleCatch2 PROPERTIES CXX_STANDARD 17)

# ---- Enable testing ----

enable_testing()
add_test(CPMExampleCatch2 CPMExampleCatch2)
