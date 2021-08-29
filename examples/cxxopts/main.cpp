#include <cxxopts.hpp>
#include <iostream>

int main(int argc, char** argv) {
  cxxopts::Options options("MyProgram", "One line description of MyProgram");

  // clang-format off
  options.add_options()
    ("h,help", "Show help")
    ("d,debug", "Enable debugging")
    ("f,file", "File name", cxxopts::value<std::string>()
  );
  // clang-format on

  auto result = options.parse(argc, argv);

  if (result["help"].as<bool>()) {
    std::cout << options.help() << std::endl;
    return 0;
  }

  for (auto arg : result.arguments()) {
    std::cout << "option: " << arg.key() << ": " << arg.value() << std::endl;
  }

  return 0;
}
