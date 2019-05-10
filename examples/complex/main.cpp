#include <lars/parser/extension.h>
#include <glue/lua.h>
#include <stdexcept>
#include <iostream>

int main() {
  // create lua state
  auto lua = glue::LuaState();
  lua.openStandardLibs();

  lua["parser"] = lars::glue::parser();
  
  // create a parser
  lua.run(R"(
    NumberMap = parser.Program.create()
    NumberMap:setRule("Whitespace", "[ \t]")
    NumberMap:setSeparatorRule("Whitespace")
    NumberMap:setRuleWithCallback("Object", "'{' KeyValue (',' KeyValue)* '}'",function(e)
      local N = e:size()-1
      local res = {}
      for i=0,N do 
        local a = e:get(i)
        res[a:get(0):evaluate()] = a:get(1):evaluate() 
      end
      return res
    end)
    NumberMap:setRule("KeyValue", "Number ':' Number")
    NumberMap:setRuleWithCallback("Number", "'-'? [0-9]+", function(e) return tonumber(e:string()); end)
    NumberMap:setStartRule("Object")
  )");

  // parse a string
  lua.run("m = NumberMap:run('{1:3, 2:-1, 3:42}')");

  // check result
  if (lua.get<int>("m[1]") != 3) throw std::runtime_error("unexpected result");
  if (lua.get<int>("m[2]") != -1) throw std::runtime_error("unexpected result");
  if (lua.get<int>("m[3]") != 42) throw std::runtime_error("unexpected result");

  return 0;
}
