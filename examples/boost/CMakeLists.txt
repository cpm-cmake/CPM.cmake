cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleBoost)

set(FETCHCONTENT_QUIET OFF) # to see downloading progress

# ---- Create binary ----

add_executable(${PROJECT_NAME} main.cpp)
target_compile_features(CPMExampleBoost PRIVATE cxx_std_17)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

# check https://github.com/boostorg/cmake if you want to add some libraries. Maybe they need some
# addtional options, like Boost::Python requires BOOST_ENABLE_PYTHON ON
set(BOOST_INCLUDE_LIBRARIES "container;asio;thread")
string(REPLACE ";" "\\\\\;" BOOST_INCLUDE_LIBRARIES "${BOOST_INCLUDE_LIBRARIES}")

# boost is a huge project and directly downloading the 'alternate release' from github is much
# faster than recursively cloning the repo.
CPMAddPackage(
  NAME Boost
  VERSION 1.85.0
  URL https://github.com/boostorg/boost/releases/download/boost-1.85.0/boost-1.85.0-cmake.tar.xz
  URL_HASH SHA256=0a9cc56ceae46986f5f4d43fe0311d90cf6d2fa9028258a95cab49ffdacf92ad
  SYSTEM TRUE # to add boost's headers like they are system. Totally unnecessary
  FIND_PACKAGE_ARGUMENTS
    "COMPONENTS thread" # "COMPONENTS ${BOOST_NOT_HEADER_ONLY_COMPONENTS_THAT_YOU_NEED}"
    # Check if it's a header only lib here:
    # https://www.boost.org/doc/libs/1_85_0/more/getting_started/unix-variants.html
  OPTIONS "BOOST_ENABLE_CMAKE ON"
          "BOOST_SKIP_INSTALL_RULES OFF" # if you want to make boost be
          # installed on your system with your package ( Profits: install only what you need ; Cons:
          # a little headache)
          "BUILD_SHARED_LIBS OFF" # it should work whether build shared or not(static)
          "BOOST_INCLUDE_LIBRARIES ${BOOST_INCLUDE_LIBRARIES}"
)

target_link_libraries(CPMExampleBoost PRIVATE Boost::asio Boost::container Boost::thread)

# # or:

# cmake-format: off

# CPMAddPackage(
#   NAME AddBoost.CMake
#   GIT_TAG 2.1
#   GITHUB_REPOSITORY Arniiiii/AddBoost.cmake
# )
#
# set(TRY_BOOST_VERSION "1.85.0")
# set(BOOST_NOT_HEADER_ONLY_COMPONENTS_THAT_YOU_NEED "thread")
# set(BOOST_HEADER_ONLY_COMPONENTS_THAT_YOU_NEED "asio")
# set(BOOST_ADD_MY_OPTIONS "BOOST_ENABLE_PYTHON ON;")
#
# add_boost(${TRY_BOOST_VERSION} ${BOOST_HEADER_ONLY_COMPONENTS_THAT_YOU_NEED}
#           ${BOOST_NOT_HEADER_ONLY_COMPONENTS_THAT_YOU_NEED} ${PROJECT_NAME}
# )
#
# # notice ${ADDBOOSTCMAKE_PACKAGEPROJECT_INSTALL_TARGETS} in the next lines:
#
# CPMAddPackage(
#   NAME PackageProject.cmake
#   VERSION 1.11.2
#   GIT_REPOSITORY "https://github.com/TheLartians/PackageProject.cmake.git"
# )
#
# packageProject(
#   NAME ${PROJECT_NAME}
#   VERSION ${PROJECT_VERSION}
#   NAMESPACE ${PROJECT_NAME}
#   BINARY_DIR ${PROJECT_BINARY_DIR}
#   INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include
#   INCLUDE_DESTINATION include/${PROJECT_NAME}
#   VERSION_HEADER "${VERSION_HEADER_LOCATION}"
#   EXPORT_HEADER "${EXPORT_HEADER_LOCATION}"
#   COMPATIBILITY "AnyNewerVersion"
#   DISABLE_VERSION_SUFFIX ON
#   DEPENDENCIES "${ADDBOOSTCMAKE_PACKAGEPROJECT_INSTALL_TARGETS}"
# )

# cmake-format: on
