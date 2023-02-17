cmake_minimum_required(VERSION 3.14...3.24)

project(CPMExampleBoost)

# ---- Create binary ----

add_executable(CPMExampleAsio deferred.cpp)
target_compile_features(CPMExampleAsio PRIVATE cxx_std_17)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

# using unofficial fork as boost's lacking good CMake support
CPMAddPackage("gh:ClausKlein/boost-cmake@1.79.2")

target_link_libraries(CPMExampleAsio PRIVATE Boost::asio)

# ---- Testing ----

enable_testing()
add_test(NAME CPMExampleAsio COMMAND CPMExampleAsio)
