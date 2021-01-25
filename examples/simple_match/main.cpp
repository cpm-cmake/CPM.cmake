#include <iostream>
#include <simple_match/simple_match.hpp>

int main(int argc, char** argv) {
  using namespace simple_match;
  using namespace simple_match::placeholders;

  std::string input;
  std::cout << "please enter a number or 'quit' to exit" << std::endl;

  while (true) {
    std::cout << "> ";
    std::getline(std::cin, input);
    if (input == "quit") {
      break;
    }
    int x;
    try {
      x = std::stoi(input);
    } catch (std::invalid_argument&) {
      std::cout << "invalid input" << std::endl;
      continue;
    }

    match(
        x, 1, []() { std::cout << "The answer is one\n"; }, 2,
        []() { std::cout << "The answer is two\n"; }, _x < 10,
        [](auto&& a) { std::cout << "The answer " << a << " is less than 10\n"; }, 10 < _x < 20,
        [](auto&& a) { std::cout << "The answer " << a << " is between 10 and 20 exclusive\n"; }, _,
        []() { std::cout << "Did not match\n"; });
  }

  return 0;
}
