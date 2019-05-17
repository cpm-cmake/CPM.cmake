#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN

#include <doctest/doctest.h>
#include <fibonacci.h>

TEST_CASE("fibonnacci"){
  CHECK(fibonnacci(0) == 0);
  CHECK(fibonnacci(1) == 1);
  CHECK(fibonnacci(2) == 1);
  CHECK(fibonnacci(3) == 2);
  CHECK(fibonnacci(4) == 3);
  CHECK(fibonnacci(5) == 5);
  CHECK(fibonnacci(13) == 233);
}

TEST_CASE("fastFibonnacci"){
  for (unsigned i=0; i<25; ++i){
    CHECK(fibonnacci(i) == fastFibonacci(i));
  }
}
