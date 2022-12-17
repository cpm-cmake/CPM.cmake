cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleBenchmark)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage("gh:cpm-cmake/testpack-fibonacci@2.0")

CPMAddPackage(
  NAME benchmark
  GITHUB_REPOSITORY google/benchmark
  VERSION 1.7.1
  OPTIONS "BENCHMARK_ENABLE_TESTING Off"
)

if(benchmark_ADDED)
  # enable c++11 to avoid compilation errors
  set_target_properties(benchmark PROPERTIES CXX_STANDARD 11)
endif()

# ---- Executable ----

add_executable(CPMExampleBenchmark "main.cpp")
target_link_libraries(CPMExampleBenchmark fibonacci benchmark)
target_compile_features(CPMExampleBenchmark PRIVATE cxx_std_17)
