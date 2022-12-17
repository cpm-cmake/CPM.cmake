#include <fibonacci.h>

#include <catch2/catch_test_macros.hpp>

TEST_CASE("fibonacci") {
  REQUIRE(fibonacci(0) == 0);
  REQUIRE(fibonacci(1) == 1);
  REQUIRE(fibonacci(2) == 1);
  REQUIRE(fibonacci(3) == 2);
  REQUIRE(fibonacci(4) == 3);
  REQUIRE(fibonacci(5) == 5);
  REQUIRE(fibonacci(13) == 233);
}

TEST_CASE("fastFibonacci") {
  for (unsigned i = 0; i < 25; ++i) {
    REQUIRE(fibonacci(i) == fastFibonacci(i));
  }
}
