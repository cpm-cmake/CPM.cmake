cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMLibSigCppExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage("gh:libsigcplusplus/libsigcplusplus#3.6.0")
if(libsigcplusplus_ADDED)
    set(SIGCPP_INCLUDE_DIRS ${libsigcplusplus_SOURCE_DIR} ${CPM_PACKAGE_libsigcplusplus_BINARY_DIR} )
    set(SIGCPP_LIBRARY sigc-3.0)
endif()

# ---- Create binary ----

add_executable(CPMLibSigCppExample main.cpp)
target_include_directories(CPMLibSigCppExample PUBLIC ${SIGCPP_INCLUDE_DIRS})
target_link_libraries(CPMLibSigCppExample ${SIGCPP_LIBRARY})
target_compile_features(CPMLibSigCppExample PRIVATE cxx_std_17)
