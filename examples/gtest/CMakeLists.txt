cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleGtest)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS NO)

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
target_compile_features(CPMExampleGtest PRIVATE cxx_std_17)

# ---- Enable testing ----

enable_testing()
add_test(CPMExampleGtest CPMExampleGtest)
