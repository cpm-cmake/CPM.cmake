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
#include <boost/container/devector.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <iostream>
#include <string>

boost::container::devector<std::string> strings;

void print(const boost::system::error_code& /*e*/) {
  for (const auto& a : strings) std::cout << a;
}

int main() {
  boost::asio::io_service io;

  strings.push_back("Hello, world!\n");

  boost::asio::deadline_timer t(io, boost::posix_time::seconds(1));
  t.async_wait(&print);

  io.run();

  return 0;
}
