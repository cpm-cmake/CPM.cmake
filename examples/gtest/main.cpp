#include <gtest/gtest.h>
#include <fibonacci.h>

TEST(FibonacciTests, BasicChecks)
{
  ASSERT_TRUE(fibonnacci(0) == 0);
  ASSERT_TRUE(fibonnacci(1) == 1);
  ASSERT_TRUE(fibonnacci(2) == 1);
  ASSERT_TRUE(fibonnacci(3) == 2);
  ASSERT_TRUE(fibonnacci(4) == 3);
  ASSERT_TRUE(fibonnacci(5) == 5);
  ASSERT_TRUE(fibonnacci(13) == 233);
}
