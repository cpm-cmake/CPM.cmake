cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMJSONExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME fmt
  VERSION 6.1.2
  VERSION_PREFIX "" # fmt uses non-prefixed git tags
  GITHUB_REPOSITORY fmtlib/fmt
)

# ---- Executable ----

add_executable(CPMFmtExample "main.cpp")
set_target_properties(CPMFmtExample PROPERTIES CXX_STANDARD 17)        
target_link_libraries(CPMFmtExample fmt)
