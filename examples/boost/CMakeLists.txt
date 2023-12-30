cmake_minimum_required(VERSION 3.16...3.28)

project(
  CPMExampleBoost
  VERSION 0.1.2
  LANGUAGES CXX
)

set(stageDir ${CMAKE_CURRENT_BINARY_DIR}/stage)
include(GNUInstallDirs)
if(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${stageDir}/${CMAKE_INSTALL_BINDIR})
endif()
if(NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${stageDir}/${CMAKE_INSTALL_LIBDIR})
endif()
if(NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${stageDir}/${CMAKE_INSTALL_LIBDIR})
endif()

set(CMAKE_INSTALL_MESSAGE LAZY)
option(BUILD_SHARED_LIBS "yes/no" YES)
if(BUILD_SHARED_LIBS)
  if(APPLE)
    set(base @loader_path)
  else()
    set(base $ORIGIN)
  endif()

  file(RELATIVE_PATH relDir ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}
       ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}
  )
  set(CMAKE_INSTALL_RPATH ${base} ${base}/${relDir})

  # FIXME: install(DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/" DESTINATION
  # ${CMAKE_INSTALL_LIBDIR})
endif()

# ---- Create binary ----

add_executable(CPMExampleBoost main.cpp)
target_compile_features(CPMExampleBoost PRIVATE cxx_std_17)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

# XXX list(APPEND BOOST_INCLUDE_LIBRARIES headers asio date_time filesystem thread)
CPMAddPackage(
  NAME Boost
  URL https://github.com/boostorg/boost/releases/download/boost-1.84.0/boost-1.84.0.tar.xz
  URL_MD5 893b5203b862eb9bbd08553e24ff146a
  EXCLUDE_FROM_ALL ON
  SYSTEM ON
)

# ---- Create a library ----

add_library(scoped_lock scoped_lock.cpp scoped_lock.hpp)
target_compile_features(scoped_lock PUBLIC cxx_std_17)

install(FILES scoped_lock.hpp TYPE INCLUDE)

# ---- Install the library ----

target_link_libraries(scoped_lock PUBLIC Boost::thread)
install(
  TARGETS scoped_lock
          boost_thread # XXX ...
          boost_atomic
          boost_chrono
          boost_container
          RUNTIME_DEPENDENCY_SET
          libDeps
)
install(RUNTIME_DEPENDENCY_SET libDeps POST_INCLUDE_REGEXES
        [[${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libboost_.*]]
)

# ---- Install the binary and its runtime dependency set ----

target_link_libraries(CPMExampleBoost PUBLIC Boost::asio Boost::date_time Boost::filesystem)

install(
  TARGETS CPMExampleBoost
          boost_asio
          boost_date_time
          boost_filesystem # XXX ...
          boost_context
          boost_coroutine
          RUNTIME_DEPENDENCY_SET
          appDeps
)
install(RUNTIME_DEPENDENCY_SET appDeps POST_INCLUDE_REGEXES
        [[${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libboost_.*]]
)

set(CPACK_PACKAGE_INSTALL_DIRECTORY /)
set(CPACK_GENERATOR TBZ2)
include(CPack)
