cmake_minimum_required(VERSION 3.14...3.31 FATAL_ERROR)

project(CPMExampleBoost LANGUAGES CXX)

# ---- Create binary ----

add_library(CPMExampleBoost main.cpp)
target_compile_features(CPMExampleBoost PRIVATE cxx_std_17)

# ---- Dependencies ----

set(env{CPM_USE_LOCAL_PACKAGES} OFF)

include(../../cmake/CPM.cmake)

set(CMAKE_SKIP_INSTALL_RULES OFF)
set(CMAKE_INSTALL_MESSAGE LAZY)
set(CMAKE_UNITY_BUILD ON)


set(BOOST_VERSION 1.87.0)
list(APPEND BOOST_INCLUDE_LIBRARIES asio container)

set(BUILD_SHARED_LIBS ON)

CPMAddPackage(
  NAME Boost
  VERSION ${BOOST_VERSION}
  URL https://github.com/boostorg/boost/releases/download/boost-${BOOST_VERSION}/boost-${BOOST_VERSION}-cmake.tar.xz
  URL_HASH SHA256=7da75f171837577a52bbf217e17f8ea576c7c246e4594d617bfde7fafd408be5
  EXCLUDE_FROM_ALL ON
  SYSTEM ON
  OPTIONS "BOOST_ENABLE_CMAKE ON" "BOOST_SKIP_INSTALL_RULES ${CMAKE_SKIP_INSTALL_RULES}"
)

# `Boost::headers` is also valid
target_link_libraries(CPMExampleBoost PUBLIC Boost::asio Boost::container)

if(CMAKE_SKIP_INSTALL_RULES)
  return()
endif()

# ---- Install rules ----

CPMAddPackage("gh:TheLartians/PackageProject.cmake@1.11.0")

packageProject(
  NAME CPMExampleBoost
  TARGETS CPMExampleBoost
  VERSION ${BOOST_VERSION}
  NAMESPACE BoostExample
  BINARY_DIR ${PROJECT_BINARY_DIR}
  ARCH_INDEPENDENT NO
  # INCLUDE_DIR ${BOOST_SOURCE}/boost
  # INCLUDE_DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/boost
  # INCLUDE_HEADER_REGEX [=[.*\.(inc|h|hpp|ipp)$]=]
  DISABLE_VERSION_SUFFIX YES
  COMPATIBILITY SameMajorVersion
  DEPENDENCIES "Boost ${BOOST_VERSION}"
  CPACK YES
)
