cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage(
  NAME lua
  GIT_REPOSITORY https://github.com/lua/lua.git
  VERSION 5.3.4
  GIT_TAG v5-3-4
  DOWNLOAD_ONLY YES
)

if (lua_ADDED)
  # lua has no CMakeLists, so we create our own target

  FILE(GLOB lua_sources ${lua_SOURCE_DIR}/*.c)
  add_library(lua STATIC ${lua_sources})

  target_include_directories(lua
    PUBLIC
      $<BUILD_INTERFACE:${lua_SOURCE_DIR}>
  )
endif()


CPMAddPackage(
  NAME sol2
  URL https://github.com/ThePhD/sol2/archive/v3.0.2.zip
  VERSION 3.0.2
  DOWNLOAD_ONLY YES
)

if (sol2_ADDED)
  add_library(sol2 INTERFACE IMPORTED)
  target_include_directories(sol2 INTERFACE ${sol2_SOURCE_DIR}/include)
  target_link_libraries(sol2 INTERFACE lua)
endif()

# ---- Executable ----

add_executable(CPMSol2Example "main.cpp")
set_target_properties(CPMSol2Example PROPERTIES CXX_STANDARD 17)        
target_link_libraries(CPMSol2Example sol2)
