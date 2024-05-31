cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(wxWidgetsExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

CPMAddPackage("gh:wxWidgets/wxWidgets@3.2.5")

# ---- Executable (with gui) ----

add_executable(wxWidgetsExample main.cpp)
target_link_libraries(wxWidgetsExample wx::core)


# ---- Executable (only console) ----

add_executable(wxWidgetsConsoleExample console.cpp)
target_compile_definitions(wxWidgetsConsoleExample PRIVATE "-DwxUSE_GUI=0")
target_link_libraries(wxWidgetsConsoleExample wx::base)
