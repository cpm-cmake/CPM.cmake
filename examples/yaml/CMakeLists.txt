cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMYamlExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME yaml-cpp
  GIT_REPOSITORY https://github.com/jbeder/yaml-cpp.git
  VERSION 0.6.3
  GIT_TAG yaml-cpp-0.6.3
  OPTIONS "YAML_CPP_BUILD_TESTS Off" "YAML_CPP_BUILD_CONTRIB Off" "YAML_CPP_BUILD_TOOLS Off"
)

# ---- Executable ----

add_executable(CPMYamlExample main.cpp)
set_target_properties(CPMYamlExample PROPERTIES CXX_STANDARD 17)
target_link_libraries(CPMYamlExample yaml-cpp)
