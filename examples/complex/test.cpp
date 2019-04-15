#include <lars/parser/extension.h>
#include <lars/lua_glue.h>
#include <stdexcept>

int main() {
  // create lua state
  auto lua = lars::LuaState();
  lua.open_libs();

  // create extensions
  lars::Extension extensions;

  // add parser library to extension
  extensions.add_extension("parser", lars::extensions::parser());

  // connect parser extension to lua
  extensions.connect(lua.get_glue());

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
  if (lua.get_numeric("m[1]") != 3) throw std::runtime_error("unexpected result");
  if (lua.get_numeric("m[2]") != -1) throw std::runtime_error("unexpected result");
  if (lua.get_numeric("m[3]") != 42) throw std::runtime_error("unexpected result");

  return 0;
}
