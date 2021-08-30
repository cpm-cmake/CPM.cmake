cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMTest_Dependency)

# ---- Dependencies ----

include(FetchContent)

FetchContent_Declare(
  Fibonacci
  GIT_REPOSITORY https://github.com/cpm-cmake/testpack-fibonacci.git
  GIT_TAG v2.0
)

FetchContent_MakeAvailable(Fibonacci)
