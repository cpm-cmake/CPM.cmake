add_test 'basic', ->(prj) {
  prj.build_cmake_lists {
    package 'gh:cpm-cmake/testpack-adder'
    exe 'using-adder', ['using-adder.cpp']
    link_libs 'using-adder', 'adder'
  }
  cfg = prj.configure

  check cfg.status.success?
}
