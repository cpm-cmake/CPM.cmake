cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMRangev3Example)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage("gh:ericniebler/range-v3#0.11.0")

# ---- Executable ----

add_executable(CPMRangev3Example main.cpp)
target_compile_features(CPMRangev3Example PRIVATE cxx_std_17)
target_link_libraries(CPMRangev3Example range-v3)
