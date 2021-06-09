cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(CPMTestingFrameworkExample)

include(../../cmake/CPM.cmake)
CPMAddPackage("bb:HEMRND/TestingFramework@0.4.1")
add_test_suites(TESTS SomeTest)
