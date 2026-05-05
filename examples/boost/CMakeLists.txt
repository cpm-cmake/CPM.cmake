cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleBoost)

# ---- Create binary ----

add_executable(CPMExampleBoost main.cpp)
target_compile_features(CPMExampleBoost PRIVATE cxx_std_17)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME Boost
  VERSION 1.86.0 # Versions less than 1.85.0 may need patches for installation targets.
  URL https://github.com/boostorg/boost/releases/download/boost-1.86.0/boost-1.86.0-cmake.tar.xz
  URL_HASH SHA256=2c5ec5edcdff47ff55e27ed9560b0a0b94b07bd07ed9928b476150e16b0efc57
  OPTIONS "BOOST_ENABLE_CMAKE ON" "BOOST_SKIP_INSTALL_RULES ON" # Set `OFF` for installation
          "BUILD_SHARED_LIBS OFF" "BOOST_INCLUDE_LIBRARIES container\\\;asio" # Note the escapes!
)

# `Boost::headers` is also valid
target_link_libraries(CPMExampleBoost PRIVATE Boost::asio Boost::container)
