cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExampleOpenUSD)

# ---- Tools ----

macro(find_targets targets dir)
  get_property(subdirectories DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)
  foreach(subdir ${subdirectories})
    find_targets(${targets} ${subdir})
  endforeach()
  get_property(current_targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)
  list(APPEND ${targets} ${current_targets})
endmacro()

function(add_prefix_to_folder prefix)
  if(CMAKE_GENERATOR MATCHES "Visual Studio")
    foreach(target ${ARGN})
      get_target_property(folder ${target} FOLDER)
      if(folder STREQUAL "folder-NOTFOUND")
        set(folder "${prefix}")
      else()
        set(folder "${prefix}/${folder}")
      endif()
      set_property(TARGET ${target} PROPERTY FOLDER "${folder}")
    endforeach()
  endif()
endfunction(add_prefix_to_folder)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

include(${CMAKE_CURRENT_SOURCE_DIR}/VEnv.cmake)

# Do not use the latest version (2022.0.0) as it fails to compile.
# The error occurs in openusd\pxr\base\work\dispatcher.cpp at line 36.
CPMAddPackage(
  NAME TBB
  VERSION 2021.13.0
  GITHUB_REPOSITORY uxlfoundation/oneTBB
  OPTIONS
    "TBB_TEST OFF")
find_targets(TBB_targets ${TBB_SOURCE_DIR})
add_prefix_to_folder(TBB ${TBB_targets})
set(TBB_INCLUDE_DIRS "")
set(TBB_tbb_LIBRARY tbb)

CPMAddPackage(
  NAME OpenSubdiv
  VERSION 3.6.0
  GITHUB_REPOSITORY PixarAnimationStudios/OpenSubdiv
  GIT_TAG v3_6_0
  OPTIONS
    "NO_EXAMPLES ON"
    "NO_TUTORIALS ON"
    "NO_REGRESSION ON"
    "NO_DOC ON"
    "NO_TESTS ON")
find_targets(OpenSubdiv_targets ${OpenSubdiv_SOURCE_DIR})
add_prefix_to_folder(OpenSubdiv ${OpenSubdiv_targets})
target_include_directories(osd_static_cpu SYSTEM PUBLIC $<BUILD_INTERFACE:${OpenSubdiv_SOURCE_DIR}>)
target_include_directories(osd_static_gpu SYSTEM PUBLIC $<BUILD_INTERFACE:${OpenSubdiv_SOURCE_DIR}>)
set(OPENSUBDIV_INCLUDE_DIR "")
set(OPENSUBDIV_OSDCPU_LIBRARY osd_static_cpu)
set(OPENSUBDIV_LIBRARIES osd_static_cpu osd_static_gpu)

CPMAddPackage(
  NAME OpenUSD
  VERSION 24.11
  GITHUB_REPOSITORY PixarAnimationStudios/OpenUSD
  PATCHES "OpenUSD.patch" # Avoid the error "The solution already contains an item named 'boost'"
                          # and use the latest version of PySide.
  OPTIONS
    "PXR_BUILD_TESTS OFF"
    "PXR_BUILD_EXAMPLES OFF"
    "PXR_BUILD_TUTORIALS OFF"
    "PXR_BUILD_HTML_DOCUMENTATION OFF")
find_targets(OpenUSD_targets ${OpenUSD_SOURCE_DIR})
add_prefix_to_folder(OpenUSD ${OpenUSD_targets})
set(OpenUSD_INCLUDE_DIR "${OpenUSD_BINARY_DIR}/include")
foreach(OpenUSD_target ${OpenUSD_targets})
  get_target_property(OpenUSD_target_TYPE ${OpenUSD_target} TYPE)
  if(OpenUSD_target_TYPE STREQUAL "SHARED_LIBRARY")
    target_include_directories(${OpenUSD_target} SYSTEM PUBLIC $<BUILD_INTERFACE:${OpenUSD_INCLUDE_DIR}>)
  elseif(OpenUSD_target_TYPE STREQUAL "EXECUTABLE")
    # It's easier to set the Path than to configure the installation of different libraries
    # TODO! Fix install
    set_target_properties(${OpenUSD_target} PROPERTIES
      VS_DEBUGGER_ENVIRONMENT "PATH=${CMAKE_INSTALL_PREFIX}/bin;${CMAKE_INSTALL_PREFIX}/lib")
  elseif(OpenUSD_target_TYPE STREQUAL "UTILITY")
    continue()
  else()
    message(FATAL_ERROR "Unknown target type: ${OpenUSD_target_TYPE} (${OpenUSD_target})")
  endif()
endforeach()

CPMAddPackage(
  NAME glfw
  VERSION 3.4
  GITHUB_REPOSITORY glfw/glfw
  GIT_TAG 3.4
  OPTIONS "BUILD_SHARED_LIBS ON"
          "GLFW_BUILD_EXAMPLES OFF"
          "GLFW_BUILD_TESTS OFF"
          "GLFW_BUILD_DOCS OFF")
find_targets(glfw_targets ${glfw_SOURCE_DIR})
add_prefix_to_folder(glfw ${glfw_targets})

# ---- Executable ----

add_executable(CPMExampleOpenUSD main.cpp)
target_compile_features(CPMExampleOpenUSD PRIVATE cxx_std_17)
target_link_libraries(CPMExampleOpenUSD glfw glf hgiGL)

install(TARGETS CPMExampleOpenUSD RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
if(MSVC)
  install(FILES $<TARGET_PDB_FILE:CPMExampleOpenUSD> DESTINATION ${CMAKE_INSTALL_BINDIR} OPTIONAL)
  # It's easier to set the Path than to configure the installation of different libraries
  # TODO! Fix install
  set_target_properties(CPMExampleOpenUSD PROPERTIES
    VS_DEBUGGER_ENVIRONMENT "PATH=${CMAKE_INSTALL_PREFIX}/bin;${CMAKE_INSTALL_PREFIX}/lib")
endif()

if(MSVC)
  add_custom_target(usdview)
  set_target_properties(usdview PROPERTIES
    VS_DEBUGGER_COMMAND "${Python3_EXECUTABLE}"
    VS_DEBUGGER_COMMAND_ARGUMENTS "${CMAKE_INSTALL_PREFIX}/bin/usdview ${CMAKE_SOURCE_DIR}/cube.usda"
    VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_INSTALL_PREFIX}/bin"
    VS_DEBUGGER_ENVIRONMENT "PYTHONPATH=$ENV{PYTHONPATH};${CMAKE_INSTALL_PREFIX}/lib/python\nPATH=$ENV{PATH};${CMAKE_INSTALL_PREFIX}/bin;${CMAKE_INSTALL_PREFIX}/lib")
endif()
