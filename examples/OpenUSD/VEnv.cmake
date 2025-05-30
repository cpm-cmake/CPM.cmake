# https://discourse.cmake.org/t/possible-to-create-a-python-virtual-env-from-cmake-and-then-find-it-with-findpython3/1132
find_package(Python3 COMPONENTS Interpreter Development REQUIRED)

set(VENV_PATH "${CMAKE_CURRENT_SOURCE_DIR}/venv")

if(NOT EXISTS "${VENV_PATH}")
  execute_process(COMMAND "${Python3_EXECUTABLE}" -m venv "${VENV_PATH}")
endif()

set(ENV{VIRTUAL_ENV} "${VENV_PATH}")
set(Python3_FIND_VIRTUALENV FIRST)
unset(Python3_EXECUTABLE)

find_package(Python3 COMPONENTS Interpreter Development REQUIRED)

execute_process(COMMAND "${Python3_EXECUTABLE}"
  -m pip install
  -r "${CMAKE_CURRENT_SOURCE_DIR}/pyrequirements.txt")

execute_process(COMMAND "${Python3_EXECUTABLE}"
  -c "import PySide6; print(PySide6.__file__)"
  OUTPUT_VARIABLE PYSIDE_BIN_DIR)

get_filename_component(PYSIDE_BIN_DIR "${PYSIDE_BIN_DIR}" DIRECTORY)
set(PYSIDE_BIN_DIR "${PYSIDE_BIN_DIR}")

install(FILES
    ${Python3_RUNTIME_LIBRARY_DIRS}/python${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR}.dll
    DESTINATION "${CMAKE_INSTALL_PREFIX}/bin")
