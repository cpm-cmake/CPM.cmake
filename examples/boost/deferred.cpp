//
// deferred_1.cpp
// ~~~~~~~~~~~~~~
//
// Copyright (c) 2003-2022 Christopher M. Kohlhoff (chris at kohlhoff dot com)
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//

#include <boost/asio.hpp>
#include <boost/asio/experimental/deferred.hpp>
#include <iostream>

using boost::asio::experimental::deferred;

int main() {
  boost::asio::io_context ctx;

  boost::asio::steady_timer timer(ctx);
  timer.expires_after(std::chrono::seconds(1));

  auto deferred_op = timer.async_wait(deferred);

  std::move(deferred_op)([](boost::system::error_code ec) {
    if (ec)
      std::cout << "timer wait finished with error: " << ec.message() << "\n";
    else
      std::cout << "timer wait finished.\n";
  });

  ctx.run();

  return 0;
}
