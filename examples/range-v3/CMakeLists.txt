cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMRangev3Example)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMFindPackage(
  NAME range-v3
  URL https://github.com/ericniebler/range-v3/archive/0.5.0.zip
  VERSION 0.5.0
  # the range-v3 CMakeLists screws with configuration options
  DOWNLOAD_ONLY True
)

if(range-v3_ADDED) 
  add_library(range-v3 INTERFACE IMPORTED)
  target_include_directories(range-v3 INTERFACE "${range-v3_SOURCE_DIR}/include")
endif()

# ---- Executable ----

add_executable(CPMRangev3Example "main.cpp")
set_target_properties(CPMRangev3Example PROPERTIES CXX_STANDARD 17)        
target_link_libraries(CPMRangev3Example range-v3)
