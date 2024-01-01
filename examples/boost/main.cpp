//
// timer.cpp
// ~~~~~~~~~
//
// Copyright (c) 2003-2016 Christopher M. Kohlhoff (chris at kohlhoff dot com)
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//

#include <boost/asio.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/filesystem.hpp>
#include <iostream>

namespace fs = boost::filesystem;
void printPathInfo() {
  std::cout << "Current path is " << fs::current_path() << '\n';
  fs::current_path(fs::temp_directory_path());
  std::cout << "The TMP path is " << fs::current_path() << '\n';
}

void print(const boost::system::error_code& /*e*/) { printPathInfo(); }

int main() {
  std::cout << "Hello, world! ...\n";

  boost::asio::io_service io;

  boost::asio::deadline_timer t(io, boost::posix_time::seconds(1));
  t.async_wait(&print);

  io.run();

  std::cout << "... Good by!\n";

  return 0;
}
