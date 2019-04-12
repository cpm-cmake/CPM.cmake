#include <lars/parser_generator.h>
#include <lars/event.h>

int main() {
  // Define the return value
  int result = 1;

  // Define grammar and evaluation rules
  lars::ParserGenerator<float> g;
  g.setSeparator(g["Whitespace"] << "[\t ]");
  g["Sum"     ] << "Add | Subtract | Product";
  g["Product" ] << "Multiply | Divide | Atomic";
  g["Atomic"  ] << "Number | '(' Sum ')'";
  g["Add"     ] << "Sum '+' Product"    >> [](auto e){ return e[0].evaluate() + e[1].evaluate(); };
  g["Subtract"] << "Sum '-' Product"    >> [](auto e){ return e[0].evaluate() - e[1].evaluate(); };
  g["Multiply"] << "Product '*' Atomic" >> [](auto e){ return e[0].evaluate() * e[1].evaluate(); };
  g["Divide"  ] << "Product '/' Atomic" >> [](auto e){ return e[0].evaluate() / e[1].evaluate(); };
  g["Number"  ] << "'-'? [0-9]+ ('.' [0-9]+)?" >> [](auto e){ return stof(e.string()); };
  g.setStart(g["Sum"]);

  // create an event
  lars::Event<float> onResult;
  onResult.connect([&](float v){ result = !(int(v) == 5); });
  
  // emit the result of a parsed string
  onResult.notify(g.run("1 + 2 * (3+4)/2 - 3"));

  // return the result
  return result;
}
