# Warning: this CMakeLists has been created only for supporting
# `cmake --install` && find_package(CPM) workflow. If you don't
# use it, then this file is not required, just download CPM.cmake
# as written in README.md.
cmake_minimum_required(VERSION 3.15) # minimal for `cmake --install`
include(cmake/CPM.cmake) # extract version
project(CPM LANGUAGES NONE)

include(GNUInstallDirs)
install(FILES ${CMAKE_CURRENT_LIST_DIR}/cmake/CPM.cmake DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/CPM)

# CPM-config.cmake stub
file(CONFIGURE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/CPM-config.cmake CONTENT [=[
include(${CMAKE_CURRENT_LIST_DIR}/CPM.cmake)
set(CPM_FOUND ON)
]=] @ONLY)	

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/CPM-config.cmake DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/CPM)
