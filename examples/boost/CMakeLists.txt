cmake_minimum_required(VERSION 3.21...3.28)

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

option(CPM_USE_LOCAL_PACKAGES "yes/no" YES)
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
endif()

set(CMAKE_INSTALL_MESSAGE LAZY)

# ---- Create binary ----

add_executable(CPMExampleBoost main.cpp)
target_compile_features(CPMExampleBoost PRIVATE cxx_std_17)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME Boost
  VERSION 1.74
  URL https://github.com/boostorg/boost/releases/download/boost-1.84.0/boost-1.84.0.tar.xz
  URL_MD5 893b5203b862eb9bbd08553e24ff146a
  FIND_PACKAGE_ARGUMENTS "COMPONENTS thread\;date_time\;filesystem"
  EXCLUDE_FROM_ALL ON
  SYSTEM ON
)

target_link_libraries(CPMExampleBoost PUBLIC Boost::headers Boost::date_time Boost::filesystem)

if(PROJECT_IS_TOP_LEVEL)
  enable_testing()
  add_test(NAME CPMExampleBoost COMMAND CPMExampleBoost)
endif()

# ---- Create a library ----

add_library(scoped_lock scoped_lock.cpp scoped_lock.hpp)
target_compile_features(scoped_lock PUBLIC cxx_std_17)
target_link_libraries(scoped_lock PUBLIC Boost::thread)
target_include_directories(
  scoped_lock PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
                     $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}>
)

if(NOT CMAKE_SKIP_INSTALL_RULES)

  # ---- Install the binary and its runtime dependency set ----
  install(
    TARGETS CPMExampleBoost
            # boost_headers boost_date_time boost_filesystem # XXX ... boost_context boost_coroutine
            RUNTIME_DEPENDENCY_SET appDeps EXPORT scoped_lockTargets
  )
  if(BUILD_SHARED_LIBS)
    install(RUNTIME_DEPENDENCY_SET appDeps POST_INCLUDE_REGEXES
            [[${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libboost_.*]] EXPORT scoped_lockTargets
    )
  endif()

  # ---- Install the library ----
  install(FILES scoped_lock.hpp DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME})
  if(NOT CPM_USE_LOCAL_PACKAGES)
    install(TARGETS boost_headers EXPORT scoped_lockTargets)
  elseif(BOOST_SRC_DIR)
    install(TARGETS boost_thread EXPORT scoped_lockTargets)
  endif()
  install(TARGETS scoped_lock RUNTIME_DEPENDENCY_SET libDeps)

  # PackageProject.cmake will be used to export our cmake config packages
  CPMAddPackage("gh:TheLartians/PackageProject.cmake@1.11.0")

  packageProject(
    NAME scoped_lock
    VERSION ${PROJECT_VERSION}
    NAMESPACE ${PROJECT_NAME}
    BINARY_DIR ${PROJECT_BINARY_DIR}
    COMPATIBILITY AnyNewerVersion
    DISABLE_VERSION_SUFFIX YES
    DEPENDENCIES "Boost 1.74"
  )

  if(BUILD_SHARED_LIBS)
    install(RUNTIME_DEPENDENCY_SET libDeps POST_INCLUDE_REGEXES
            [[${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libboost_.*]] EXPORT scoped_lockTargets
    )
  endif()

  set(CPACK_PACKAGE_INSTALL_DIRECTORY /)
  set(CPACK_GENERATOR TBZ2)
  include(CPack)
endif()
