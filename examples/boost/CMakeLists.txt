cmake_minimum_required(VERSION 3.14...3.28)

project(CPMExampleBoost VERSION 0.1.2 LANGUAGES CXX)

# ---- Create binary ----

add_executable(CPMExampleBoost main.cpp)
target_compile_features(CPMExampleBoost PRIVATE cxx_std_17)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)
include(FetchContent)

option(BUILD_SHARED_LIBS "yes/no" YES)

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
install(TARGETS scoped_lock # XXX boost_thread
                RUNTIME_DEPENDENCY_SET libDeps
)
install(RUNTIME_DEPENDENCY_SET libDeps)

# ---- Install the binary and its runtime dependeny set ----

target_link_libraries(CPMExampleBoost PUBLIC Boost::asio Boost::date_time Boost::filesystem)
install(TARGETS CPMExampleBoost # XXX boost_asio boost_date_time boost_filesystem
                RUNTIME_DEPENDENCY_SET appDeps
)
install(RUNTIME_DEPENDENCY_SET appDeps)

set(CPACK_PACKAGE_INSTALL_DIRECTORY /)
set(CPACK_GENERATOR TBZ2)
include(CPack)
