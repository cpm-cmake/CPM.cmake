cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMEnTTExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME EnTT
  VERSION 3.1.1
  GITHUB_REPOSITORY skypjack/entt
  # EnTT's CMakeLists screws with configuration options
  DOWNLOAD_ONLY True
)

if(EnTT_ADDED)
  add_library(EnTT INTERFACE)
  target_include_directories(EnTT SYSTEM INTERFACE ${EnTT_SOURCE_DIR}/src)
endif()

# ---- Executable ----

add_executable(CPMEnTTExample main.cpp)
target_compile_features(CPMEnTTExample PRIVATE cxx_std_17)
target_link_libraries(CPMEnTTExample EnTT)
