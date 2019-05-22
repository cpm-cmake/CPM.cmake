cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME range-v3
  URL https://github.com/ericniebler/range-v3/archive/0.5.0.zip
  VERSION 0.5.0
)

# ---- Executable ----

add_executable(CPMRangev3Example "main.cpp")
set_target_properties(CPMRangev3Example PROPERTIES CXX_STANDARD 17)        
target_link_libraries(CPMRangev3Example range-v3)

