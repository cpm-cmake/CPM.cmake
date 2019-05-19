cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME nlohmann_json
  VERSION 3.6.1  
  # not using the repo as it takes forever to clone
  URL https://github.com/nlohmann/json/releases/download/v3.6.1/include.zip
  URL_HASH SHA256=69cc88207ce91347ea530b227ff0776db82dcb8de6704e1a3d74f4841bc651cf
)

add_library(nlohmann_json INTERFACE)
target_include_directories(nlohmann_json INTERFACE ${nlohmann_json_SOURCE_DIR})

# ---- Executable ----

add_executable(CPMJSONExample "main.cpp")
set_target_properties(CPMJSONExample PROPERTIES CXX_STANDARD 17)        
target_link_libraries(CPMJSONExample nlohmann_json)
