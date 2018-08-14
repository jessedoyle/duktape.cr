require "./duktape"

ctx = Duktape::Sandbox.new
ctx.push_object
ctx.push_proc(1) do |ptr|
  env = Duktape::Sandbox.new(ptr)
  env.push_string("id")
  env.call_success
end
ctx.put_prop_string(-2, "resolve")
ctx.push_proc(1) do |ptr|
  env = Duktape::Sandbox.new(ptr)
  env.push_string("module.exports = { hello: function() { print('hello!'); }};")
  env.call_success
end
ctx.put_prop_string(-2, "load")
Duktape::BuiltIn::Require.new(ctx).import!
ctx.eval!("const foo = require('foo'); foo.hello();")
