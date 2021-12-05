cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleBoost)

# ---- Create binary ----

add_executable(CPMExampleBoost main.cpp)
target_compile_features(CPMExampleBoost PRIVATE cxx_std_17)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME Boost
  VERSION 1.77.0
  GITHUB_REPOSITORY "boostorg/boost"
  GIT_TAG "boost-1.77.0"
)

target_link_libraries(CPMExampleBoost PRIVATE Boost::asio)
