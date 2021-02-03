cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMJSONExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME nlohmann_json
  VERSION 3.9.1
  # not using the repo as it takes forever to clone
  URL https://github.com/nlohmann/json/releases/download/v3.9.1/include.zip
  URL_HASH SHA256=6bea5877b1541d353bd77bdfbdb2696333ae5ed8f9e8cc22df657192218cad91
)

if(nlohmann_json_ADDED)
  add_library(nlohmann_json INTERFACE)
  target_include_directories(nlohmann_json INTERFACE ${nlohmann_json_SOURCE_DIR})
endif()

# ---- Executable ----

add_executable(CPMJSONExample main.cpp)
set_target_properties(CPMJSONExample PROPERTIES CXX_STANDARD 17)
target_link_libraries(CPMJSONExample nlohmann_json)
