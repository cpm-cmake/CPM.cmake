cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleCereal)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME cereal
  VERSION 1.3.0
  GITHUB_REPOSITORY USCiLab/cereal
  OPTIONS "SKIP_PORTABILITY_TEST ON" "JUST_INSTALL_CEREAL ON"
)

# ---- Create binary ----

add_executable(CPMExampleCereal main.cpp)
target_link_libraries(CPMExampleCereal cereal)
target_compile_features(CPMExampleCereal PRIVATE cxx_std_17)
