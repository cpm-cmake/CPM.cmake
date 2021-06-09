#include <HEM/TestingFramework.hpp>

using namespace fakeit;

class ITest {
public:
  virtual int getInt() = 0;
};

TEST_CASE("Testing Framework Test") {
  constexpr int someIntValue = 123456;

  Mock<ITest> testMock;
  When(Method(testMock, getInt)).Return(someIntValue);

  int readValue = testMock.get().getInt();

  REQUIRE(readValue == someIntValue);
}