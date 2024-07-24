cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleBoost)

# ---- Create binary ----

add_executable(${PROJECT_NAME} main.cpp)
target_compile_features(CPMExampleBoost PRIVATE cxx_std_17)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME AddBoost.CMake
  GIT_TAG main
  GITHUB_REPOSITORY Arniiiii/AddBoost.cmake
)

set(TRY_BOOST_VERSION "1.85.0")
set(BOOST_NOT_HEADER_ONLY_COMPONENTS_THAT_YOU_NEED "thread")
set(BOOST_HEADER_ONLY_COMPONENTS_THAT_YOU_NEED "asio")

add_boost(${TRY_BOOST_VERSION} ${BOOST_HEADER_ONLY_COMPONENTS_THAT_YOU_NEED}
          ${BOOST_NOT_HEADER_ONLY_COMPONENTS_THAT_YOU_NEED} ${PROJECT_NAME} boost_install_targets
)

# notice ${boost_install_targets} in the next lines:

# CPMAddPackage( NAME PackageProject.cmake VERSION 1.11.2 GIT_REPOSITORY
# "https://github.com/TheLartians/PackageProject.cmake.git" )
#
# packageProject( NAME ${PROJECT_NAME} VERSION ${PROJECT_VERSION} NAMESPACE ${PROJECT_NAME}
# BINARY_DIR ${PROJECT_BINARY_DIR} INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include INCLUDE_DESTINATION
# include/${PROJECT_NAME} VERSION_HEADER "${VERSION_HEADER_LOCATION}" EXPORT_HEADER
# "${EXPORT_HEADER_LOCATION}" COMPATIBILITY "AnyNewerVersion" DISABLE_VERSION_SUFFIX ON DEPENDENCIES
# "${boost_install_targets}" )
