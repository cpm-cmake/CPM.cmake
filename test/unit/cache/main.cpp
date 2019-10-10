#define CATCH_CONFIG_MAIN

#include <catch2/catch.hpp>
#include <fibonacci.h>

TEST_CASE("fibonnacci"){
  REQUIRE(fibonnacci(0) == 0);
  REQUIRE(fibonnacci(1) == 1);
  REQUIRE(fibonnacci(2) == 1);
  REQUIRE(fibonnacci(3) == 2);
  REQUIRE(fibonnacci(4) == 3);
  REQUIRE(fibonnacci(5) == 5);
}
