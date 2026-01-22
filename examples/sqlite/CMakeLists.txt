cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMSqliteExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

# sqlite - You know it, you love it!
CPMAddPackage(
  NAME sqlite
  URL https://www.sqlite.org/2024/sqlite-amalgamation-3460000.zip
  URL_HASH SHA256=712a7d09d2a22652fb06a49af516e051979a3984adb067da86760e60ed51a7f5
  PATCHES sqlite.patch
)

add_executable(CPMSqliteExample main.cpp)
target_link_libraries(CPMSqliteExample sqlite)
