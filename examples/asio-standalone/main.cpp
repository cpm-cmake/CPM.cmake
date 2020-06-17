
#include "asio/io_context.hpp"
#include "asio/signal_set.hpp"

int main()
{
    asio::io_context ioc;

    asio::signal_set signals(ioc, SIGINT, SIGTERM);
    signals.async_wait([&ioc](std::error_code, int) {
        ioc.stop();
    });

    ioc.run();

    return 0;
}
