cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleBenchmark)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME fibonacci
  GITLAB_REPOSITORY TheLartians/Fibonacci
  VERSION 2.0
)

CPMAddPackage(
  NAME benchmark
  GITHUB_REPOSITORY google/benchmark
  VERSION 1.5.0
  OPTIONS "BENCHMARK_ENABLE_TESTING Off"
)

if(benchmark_ADDED)
  # patch google benchmark target
  set_target_properties(benchmark PROPERTIES CXX_STANDARD 17)
endif()

# ---- Executable ----

add_executable(CPMExampleBenchmark "main.cpp")
target_link_libraries(CPMExampleBenchmark fibonacci benchmark)
target_compile_features(CPMExampleBenchmark PRIVATE cxx_std_17)
