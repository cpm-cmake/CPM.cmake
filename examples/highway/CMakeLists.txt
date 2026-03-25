cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMExamplePatchHighway)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

# Google's highway Includes a SIMD sorting function that is faster than x86-simd-sort for larger
# arrays. See: https://github.com/google/highway/blob/master/g3doc/quick_reference.md
CPMAddPackage(
  NAME highway
  URL https://github.com/google/highway/archive/refs/tags/1.1.0.tar.gz
  URL_HASH SHA256=354a8b4539b588e70b98ec70844273e3f2741302c4c377bcc4e81b3d1866f7c9
  PATCHES "highway.patch" # This adds SYSTEM to the includes.
  OPTIONS "HWY_ENABLE_EXAMPLES OFF" "HWY_ENABLE_INSTALL OFF" "HWY_ENABLE_TESTS OFF"
)

# ---- Executable ----

if(LINUX)
  # This would cause a float compare error inside the highway header code if the patch is NOT
  # applied.
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wfloat-equal")
endif()

add_executable(CPMExamplePatchHighway "main.cpp")
target_link_libraries(CPMExamplePatchHighway hwy hwy_contrib)
