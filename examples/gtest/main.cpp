#include <fibonacci.h>
#include <gtest/gtest.h>

TEST(FibonacciTests, BasicChecks) {
  ASSERT_TRUE(fibonacci(0) == 0);
  ASSERT_TRUE(fibonacci(1) == 1);
  ASSERT_TRUE(fibonacci(2) == 1);
  ASSERT_TRUE(fibonacci(3) == 2);
  ASSERT_TRUE(fibonacci(4) == 3);
  ASSERT_TRUE(fibonacci(5) == 5);
  ASSERT_TRUE(fibonacci(13) == 233);
}
