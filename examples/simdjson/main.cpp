#include <iostream>

#include "simdjson.h"
using namespace simdjson;

int main() {
  ondemand::parser parser;
  auto cars_json = R"( [
    { "make": "Toyota", "model": "Camry",  "year": 2018, "tire_pressure": [ 40.1, 39.9, 37.7, 40.4 ] },
    { "make": "Kia",    "model": "Soul",   "year": 2012, "tire_pressure": [ 30.1, 31.0, 28.6, 28.7 ] },
    { "make": "Toyota", "model": "Tercel", "year": 1999, "tire_pressure": [ 29.8, 30.0, 30.2, 30.5 ] }
  ] )"_padded;

  // Iterating through an array of objects
  for (ondemand::object car : parser.iterate(cars_json)) {
    // Accessing a field by name
    std::cout << "Make/Model: " << std::string_view(car["make"]) << "/"
              << std::string_view(car["model"]) << std::endl;

    // Casting a JSON element to an integer
    uint64_t year = car["year"];
    std::cout << "- This car is " << 2020 - year << " years old." << std::endl;

    // Iterating through an array of floats
    double total_tire_pressure = 0;
    for (double tire_pressure : car["tire_pressure"]) {
      total_tire_pressure += tire_pressure;
    }
    std::cout << "- Average tire pressure: " << (total_tire_pressure / 4) << std::endl;
  }
}