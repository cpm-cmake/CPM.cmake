#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN

#include <doctest/doctest.h>
#include <fibonacci.h>

TEST_CASE("fibonacci") {
  CHECK(fibonacci(0) == 0);
  CHECK(fibonacci(1) == 1);
  CHECK(fibonacci(2) == 1);
  CHECK(fibonacci(3) == 2);
  CHECK(fibonacci(4) == 3);
  CHECK(fibonacci(5) == 5);
  CHECK(fibonacci(13) == 233);
}

TEST_CASE("fastfibonacci") {
  for (unsigned i = 0; i < 25; ++i) {
    CHECK(fibonacci(i) == fastFibonacci(i));
  }
}
