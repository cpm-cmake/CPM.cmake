cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleBoost)

# ---- Create binary ----

add_executable(CPMExampleBoost main.cpp)
target_compile_features(CPMExampleBoost PRIVATE cxx_std_17)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

# boost-cmake currently doesn't tag versions, so we use the according boost version
CPMAddPackage("gh:Orphis/boost-cmake#7f97a08b64bd5d2e53e932ddf80c40544cf45edf@1.71.0")

find_package(Threads REQUIRED)

target_link_libraries(CPMExampleBoost PRIVATE Boost::system Threads::Threads)
