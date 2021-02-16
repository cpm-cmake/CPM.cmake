project(BrokenDependency)

add_custom_target(error ALL ${CMAKE_COMMAND} -E false)
