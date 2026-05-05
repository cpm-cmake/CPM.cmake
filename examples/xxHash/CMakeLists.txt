cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMxxHashExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  GITHUB_REPOSITORY Cyan4973/xxHash
  GIT_TAG v0.8.2
  OPTIONS "XXHASH_BUILD_ENABLE_INLINE_API OFF" "XXHASH_BUILD_XXHSUM OFF"
  SOURCE_SUBDIR cmake_unofficial
)

# ---- Executable ----

add_executable(CPMxxHashExample main.cpp)
target_compile_features(CPMxxHashExample PRIVATE cxx_std_17)
target_link_libraries(CPMxxHashExample xxHash::xxhash)
