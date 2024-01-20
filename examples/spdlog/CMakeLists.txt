cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMSpdlogExample)

# ---- Dependencies ----

include(../../cmake/CPM.cmake)

# CPMAddPackage("gh:gabime/spdlog@1.12.0")

# spdlog uses fmt and bundles that dependency. If you want to use fmt in your project as well, you
# can let spdlog reuse fmt from CPM.cmake like this:
#
# cmake-format: off
#
CPMAddPackage("gh:fmtlib/fmt#10.0.0")
CPMAddPackage(
  GITHUB_REPOSITORY gabime/spdlog
  VERSION 1.12.0
  OPTIONS "SPDLOG_FMT_EXTERNAL 1"
          "SPDLOG_INSTALL 1"
  SYSTEM ON
)
#
# cmake-format: on

# ---- Executable ----

add_executable(CPMSpdlogExample main.cpp)
target_compile_features(CPMSpdlogExample PRIVATE cxx_std_17)
target_link_libraries(CPMSpdlogExample spdlog::spdlog)
