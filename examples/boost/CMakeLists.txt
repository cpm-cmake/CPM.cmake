cmake_minimum_required(VERSION 3.21...3.28)

set(CMAKE_CXX_STANDARD 17)

cmake_policy(SET CMP0097 NEW)

include(FetchContent)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
  cmake_policy(SET CMP0135 NEW)
endif()

# Add project_options from https://github.com/aminya/project_options Change the version in the
# following URL to update the package (watch the releases of the repository for future updates)
set(PROJECT_OPTIONS_VERSION "v0.33.0")
FetchContent_Declare(
  _project_options
  GIT_SUBMODULES ""
  URL https://github.com/aminya/project_options/archive/refs/tags/${PROJECT_OPTIONS_VERSION}.zip
)

FetchContent_MakeAvailable(_project_options)
include(${_project_options_SOURCE_DIR}/Index.cmake)

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

# cmake-format: off
project_options(
  PREFIX ${PROJECT_NAME}
  ENABLE_CACHE
  # ENABLE_CONAN
  # ENABLE_SANITIZER_ADDRESS
  # ENABLE_SANITIZER_UNDEFINED_BEHAVIOR
  # ENABLE_SANITIZER_THREAD
  # ENABLE_SANITIZER_MEMORY
  # ENABLE_STACK_PROTECTION
  # ENABLE_OVERFLOW_PROTECTION
  # WARNINGS_AS_ERRORS
)
# cmake-format: on

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
  if(BOOST_SRC_DIR)
    target_link_libraries(CPMExampleBoost PUBLIC Boost::asio)
    target_find_dependencies(
      CPMExampleBoost PUBLIC_CONFIG "boost_headers;boost_date_time;boost_filesystem"
    )
    target_find_dependencies(scoped_lock PUBLIC_CONFIG boost_thread)
    install(FILES scoped_lock.hpp DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME})
    install(
      TARGETS boost_headers
              boost_algorithm
              boost_align
              boost_array
              boost_asio
              boost_assert
              boost_atomic
              boost_bind
              boost_chrono
              boost_concept_check
              boost_config
              boost_container
              boost_container_hash
              boost_context
              boost_conversion
              boost_core
              boost_coroutine
              boost_date_time
              boost_describe
              boost_detail
              boost_exception
              boost_filesystem
              boost_function
              boost_function_types
              boost_functional
              boost_fusion
              boost_integer
              boost_intrusive
              boost_io
              boost_iterator
              boost_lexical_cast
              boost_move
              boost_mp11
              boost_mpl
              boost_numeric_conversion
              boost_optional
              boost_pool
              boost_predef
              boost_preprocessor
              boost_range
              boost_ratio
              boost_regex
              boost_smart_ptr
              boost_static_assert
              boost_system
              boost_thread
              boost_throw_exception
              boost_tokenizer
              boost_tuple
              boost_type_traits
              boost_typeof
              boost_unordered
              boost_utility
              boost_variant2
              boost_winapi
      EXPORT ${PROJECT_NAME}
    )

    # Package the project
    package_project(TARGETS CPMExampleBoost scoped_lock)
  else()
    # ---- Install the binary and its runtime dependency set ----
    install(
      TARGETS CPMExampleBoost
              # boost_headers boost_date_time boost_filesystem # XXX ... boost_context
              # boost_coroutine
              RUNTIME_DEPENDENCY_SET
              appDeps
      EXPORT scoped_lockTargets
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
  endif()

  set(CPACK_PACKAGE_INSTALL_DIRECTORY /)
  set(CPACK_GENERATOR TBZ2)
  include(CPack)
endif()
