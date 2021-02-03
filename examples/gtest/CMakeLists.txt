cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleGtest)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME fibonacci
  GITLAB_REPOSITORY TheLartians/Fibonacci
  VERSION 2.0
)

CPMAddPackage(
  NAME googletest
  GITHUB_REPOSITORY google/googletest
  GIT_TAG release-1.10.0
  VERSION 1.10.0
  OPTIONS "INSTALL_GTEST OFF" "gtest_force_shared_crt"
)

# ---- Create binary ----

add_executable(CPMExampleGtest main.cpp)
target_link_libraries(CPMExampleGtest fibonacci gtest gtest_main gmock)
set_target_properties(CPMExampleGtest PROPERTIES CXX_STANDARD 17)

# ---- Enable testing ----

enable_testing()
add_test(CPMExampleGtest CPMExampleGtest)
