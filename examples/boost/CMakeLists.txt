cmake_minimum_required(VERSION 3.14...3.26)

project(CPMExampleBoost)

# ---- Create binary ----

add_executable(CPMExampleAsio deferred.cpp)
target_compile_features(CPMExampleAsio PRIVATE cxx_std_17)

add_executable(CPMExampleRegex regex.cpp)
target_compile_features(CPMExampleRegex PRIVATE cxx_std_17)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

# using unofficial fork as boost's lacking good CMake support for user
CPMAddPackage("gh:ClausKlein/boost-cmake@1.80.0")

target_link_libraries(CPMExampleAsio PRIVATE Boost::asio)
target_link_libraries(CPMExampleRegex PRIVATE Boost::regex)

# ---- Testing ----

enable_testing()

add_test(NAME CPMExampleAsio COMMAND CPMExampleAsio)
add_test(NAME CPMExampleRegex COMMAND CPMExampleAsio)
