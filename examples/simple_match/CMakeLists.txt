cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMSimpleMatchExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME simple_match
  GIT_REPOSITORY https://github.com/jbandela/simple_match.git
  GIT_TAG a3ab17f3d98db302de68ad85ed399a42ae41889e
  DOWNLOAD_ONLY True
)

if(simple_match_ADDED)
  add_library(simple_match INTERFACE IMPORTED)
  target_include_directories(simple_match SYSTEM INTERFACE "${simple_match_SOURCE_DIR}/include")
endif()

# ---- Executable ----

add_executable(CPMSimpleMatchExample main.cpp)
target_compile_features(CPMSimpleMatchExample PRIVATE cxx_std_17)
target_link_libraries(CPMSimpleMatchExample simple_match)
