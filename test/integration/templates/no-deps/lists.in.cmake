cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(no-deps)

include("%{cpm_path}")

add_executable(no-deps main.c)
