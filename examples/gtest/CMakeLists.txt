cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleGtest)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage("gh:cpm-cmake/testpack-fibonacci@2.0")

CPMAddPackage(
  NAME googletest
  GITHUB_REPOSITORY google/googletest
  # GIT_TAG v1.14.0
  VERSION 1.14.0
  OPTIONS "INSTALL_GTEST OFF" "gtest_force_shared_crt"
)

# ---- Create binary ----

add_executable(CPMExampleGtest main.cpp)
target_link_libraries(CPMExampleGtest fibonacci GTest::gtest_main GTest::gmock)
target_compile_features(CPMExampleGtest PRIVATE cxx_std_17)

# ---- Enable testing ----

enable_testing()
add_test(CPMExampleGtest CPMExampleGtest)
