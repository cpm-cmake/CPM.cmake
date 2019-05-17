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
  REQUIRE(fibonnacci(13) == 233);
}

TEST_CASE("fastFibonnacci"){
  for (unsigned i=0; i<25; ++i){
    REQUIRE(fibonnacci(i) == fastFibonacci(i));
  }
}
