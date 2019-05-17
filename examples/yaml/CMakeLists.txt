cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME yaml-cpp
  GIT_REPOSITORY https://github.com/jbeder/yaml-cpp.git
  # 0.6.2 uses old CMake syntax
  VERSION 0.6.3                                  
  # 0.6.3 not released yet  
  GIT_TAG 012269756149ae99745b6dafefd415843d7420bb 
  OPTIONS
    "YAML_CPP_BUILD_TESTS Off"
    "YAML_CPP_BUILD_CONTRIB Off"
    "YAML_CPP_BUILD_TOOLS Off"
  )

# ---- Executable ----

add_executable(CPMYamlExample "main.cpp")
set_target_properties(CPMYamlExample PROPERTIES CXX_STANDARD 17)        
target_link_libraries(CPMYamlExample yaml-cpp)

