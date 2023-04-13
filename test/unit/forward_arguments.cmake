cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

set(input "a;;b;c;;;;def;g;;")
cpm_encode_empty_arguments("${input}" encoded)
foreach(arg IN LISTS encoded)
  assert_not_equal("${arg}" "")
endforeach()
assert_equal("${contains_empty_arg}" "")
cpm_decode_empty_arguments("${encoded}" decoded)
assert_equal("${decoded}" "${input}")

# ignore source cache if set
set(CPM_SOURCE_CACHE "")

# Intercept underlying `FetchContent_Declare`
function(FetchContent_Declare)
  set_property(GLOBAL PROPERTY last_FetchContent_Declare_ARGN "${ARGN}")
endfunction()
cpm_declare_fetch(PACKAGE VERSION INFO EMPTY "" ANOTHER)

# TEST:`cpm_declare_fetch` shall forward empty arguments
get_property(last_FetchContent_Declare_ARGN GLOBAL PROPERTY last_FetchContent_Declare_ARGN)
assert_equal("${last_FetchContent_Declare_ARGN}" "PACKAGE;EMPTY;;ANOTHER")

# TEST:`CPMDeclarePackage` shall store all including empty
CPMDeclarePackage(FOO EMPTY "" ANOTHER)
assert_equal("${CPM_DECLARATION_FOO}" "EMPTY;;ANOTHER")

# Stub the actual fetch
set(fibonacci_POPULATED YES)
set(fibonacci_SOURCE_DIR ".")
set(fibonacci_BINARY_DIR ".")
macro(FetchContent_GetProperties)

endmacro()

# TEST:`CPMAddPackage` shall call `FetchContent_declare` with unmodified arguments including any
# Empty-string arguments
CPMAddPackage(
  NAME fibonacci
  GIT_REPOSITORY https://github.com/cpm-cmake/testpack-fibonacci.git
  VERSION 1.2.3 EMPTY_OPTION "" COMMAND_WITH_EMPTY_ARG foo "" bar
)
get_property(last_FetchContent_Declare_ARGN GLOBAL PROPERTY last_FetchContent_Declare_ARGN)
assert_equal(
  "${last_FetchContent_Declare_ARGN}"
  "fibonacci;EMPTY_OPTION;;COMMAND_WITH_EMPTY_ARG;foo;;bar;GIT_REPOSITORY;https://github.com/cpm-cmake/testpack-fibonacci.git;GIT_TAG;v1.2.3"
)

# remove generated files
file(REMOVE_RECURSE ${CPM_MODULE_PATH})
file(REMOVE ${CPM_PACKAGE_LOCK_FILE})
