cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleDoctest)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME fibonacci
  GITLAB_REPOSITORY TheLartians/Fibonacci
  VERSION 2.0
)

CPMAddPackage(
  NAME doctest
  GITHUB_REPOSITORY onqtam/doctest
  GIT_TAG 2.4.5
)

# ---- Create binary ----

add_executable(CPMExampleDoctest main.cpp)
target_link_libraries(CPMExampleDoctest fibonacci doctest)
set_target_properties(CPMExampleDoctest PROPERTIES CXX_STANDARD 17)

# ---- Enable testing ----

enable_testing()
add_test(CPMExampleDoctest CPMExampleDoctest)
