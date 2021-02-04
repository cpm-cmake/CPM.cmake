cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleBoost)

# ---- Create binary ----

add_executable(CPMExampleBoost main.cpp)
target_compile_features(CPMExampleBoost PRIVATE cxx_std_17)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMFindPackage(
  NAME Boost
  GITHUB_REPOSITORY Orphis/boost-cmake
  VERSION 1.67.0
  FIND_PACKAGE_ARGUMENTS "COMPONENTS system"
)

find_package(Threads REQUIRED)

target_link_libraries(CPMExampleBoost PRIVATE Boost::system Threads::Threads)
