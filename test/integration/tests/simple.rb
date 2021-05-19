add_test('basic') { |prj|
  prj.set_body <<~CMAKE
    CPMAddPackage("gh:cpm-cmake/testpack-adder")
    add_executable(using-adder using-adder.cpp)
    target_link_libraries(using-adder PRIVATE adder)
  CMAKE
}
