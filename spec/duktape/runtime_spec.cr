require "../spec_helper"
require "../../src/duktape/runtime"

# We need access to the raw context to test some things
module Duktape
  class Runtime
    def ctx
      @context
    end
  end
end

describe Duktape::Runtime do
  describe "initialize" do
    context "without arguments" do
      it "should create a Runtime instance" do
        rt = Duktape::Runtime.new

        rt.should be_a(Duktape::Runtime)
      end
    end

    context "with timeout argument" do
      it "should create a Runtime instance" do
        rt = Duktape::Runtime.new 1000

        rt.should be_a(Duktape::Runtime)
      end
    end

    context "with a block argument" do
      it "should pass a Duktape::Sandbox to init JS code with" do
        rt = Duktape::Runtime.new do |sbx|
          sbx.should be_a(Duktape::Sandbox)
          sbx.eval!("function add(num){ return num + num; }")
        end

        rt.eval("add(9);").should eq(18)
        rt.should be_a(Duktape::Runtime)
        rt.ctx.get_top.should eq(0)
      end
    end

    context "with timeout and a block argument" do
      it "should pass a Duktape::Sandbox to init JS code with" do
        rt = Duktape::Runtime.new 1000 do |sbx|
          sbx.should be_a(Duktape::Sandbox)
          sbx.eval!("function add(num){ return num + num; }")
        end

        rt.eval("add(9);").should eq(18)
        rt.should be_a(Duktape::Runtime)
        rt.ctx.get_top.should eq(0)
      end
    end

    context "with a Duktape::Context argument" do
      context "without a block argument" do
        it "executes code on the underlying context" do
          ctx = Duktape::Context.new
          rt = Duktape::Runtime.new ctx

          rt.call("Duktape.version").should be_a(Float64)
          rt.should be_a(Duktape::Runtime)
        end
      end

      context "with a block argument" do
        it "yeilds a Duktape::Context instance for initialization" do
          ctx = Duktape::Context.new
          rt = Duktape::Runtime.new(ctx) do |env|
            env.should be_a(Duktape::Context)
            env.eval!("function add(num){ return num + num; }")
          end

          rt.eval("add(9);").should eq(18)
          rt.should be_a(Duktape::Runtime)
          rt.ctx.get_top.should eq(0)
        end
      end
    end
  end

  describe "call" do
    it "should accept signed ints as arguments" do
      rt = Duktape::Runtime.new
      val = rt.call("Math.sqrt", 9_i32)

      val.should eq(3)
    end

    it "should accept unsigned ints as arguments" do
      rt = Duktape::Runtime.new
      val = rt.call("Math.sqrt", 9_u32)

      val.should eq(3)
    end

    it "should accept booleans as arguments" do
      rt = Duktape::Runtime.new
      val = rt.call("Boolean", false)

      val.should eq(false)
      val.should be_a(Bool)
    end

    it "should accept strings as arguments" do
      rt = Duktape::Runtime.new
      val = rt.call("parseInt", "10")

      val.should eq(10)
    end

    it "should call to_s on symbol arguments" do
      rt = Duktape::Runtime.new
      val = rt.call("JSON.stringify", :some_text)

      val.should eq("\"some_text\"")
    end

    it "should accept floats as arguments" do
      rt = Duktape::Runtime.new do |sbx|
        sbx.eval!("function add(a, b) { return a + b; }")
      end
      val = rt.call("add", 3.14159_f32, -16_f64).as(Float64)

      val.should be_a(Float64)
      val.to_s.should eq("-12.858409881591797")
    end

    it "should accept arrays as arguments" do
      rt = Duktape::Runtime.new
      val = rt.call(["JSON", "stringify"], [true, 1, "test", :sym])

      val.should be_a(String)
      val.should eq("[true,1,\"test\",\"sym\"]")
    end

    it "should accept nested arrays as arguments" do
      rt = Duktape::Runtime.new
      val = rt.call(["JSON", "stringify"], [1, [2, [3, 4]]])

      val.should be_a(String)
      val.should eq("[1,[2,[3,4]]]")
    end

    it "should accept hashes as arguments" do
      rt = Duktape::Runtime.new
      val = rt.call("JSON.stringify", {"a" => "test", "b" => 123})

      val.should be_a(String)
      val.should eq("{\"a\":\"test\",\"b\":123}")
    end

    it "should accept nested hashes and arrays as arguments" do
      rt = Duktape::Runtime.new
      val = rt.call("JSON.stringify", {"a" => [1, 2, {"three" => "four"}]})

      val.should be_a(String)
      val.should eq("{\"a\":[1,2,{\"three\":\"four\"}]}")
    end

    it "should accept NamedTuples as arguments" do
      rt = Duktape::Runtime.new
      val = rt.call("JSON.stringify", {a: "test", b: 123})

      val.should be_a(String)
      val.should eq("{\"a\":\"test\",\"b\":123}")
    end

    it "should return a crystal Array of JSPrimitive" do
      rt = Duktape::Runtime.new do |sbx|
        sbx.eval!("function same(obj){ return obj; }")
      end
      val = rt.call("same", [1, 2, ["three", "four"]])

      val.should be_a(Duktape::JSPrimitive)
      val.should eq([1, 2, ["three", "four"]])
    end

    it "should return a crystal Hash of JSPrimtive" do
      rt = Duktape::Runtime.new do |sbx|
        sbx.eval!("function same(obj){ return obj; }")
      end
      val = rt.call("same", {"a" => "1", "b" => "2", "c" => [3, true]})

      val.should be_a(Duktape::JSPrimitive)
      val.should eq({"a" => "1", "b" => "2", "c" => [3, true]})
    end

    context "with a single property name" do
      it "should call the property with the args" do
        rt = Duktape::Runtime.new do |sbx|
          sbx.eval!(";function test(num) { return num - 1; }")
        end

        val = rt.call("test", 123)

        val.should eq(122)
        val.should be_a(Float64)
      end

      it "should call a key without arguments" do
        rt = Duktape::Runtime.new
        val = rt.call("Math.PI").as(Float64)

        val.should_not be_nil
        val.floor.should eq(3)
      end

      it "should raise a Duktape::TypeError if an error was thrown" do
        rt = Duktape::Runtime.new

        expect_raises(Duktape::TypeError, TYPE_REGEX) do
          rt.call("JSON.__invalid", 123)
        end
      end

      it "should have an empty stack after the call" do
        rt = Duktape::Runtime.new
        val = rt.call("JSON.stringify", {"a" => true, "b" => -10})

        val.should be_a(String)
        val.should eq("{\"a\":true,\"b\":-10}")
        rt.ctx.get_top.should eq(0)
      end
    end

    context "with multiple property names" do
      it "should call the nested property with arguments" do
        rt = Duktape::Runtime.new
        val = rt.call(["JSON", "stringify"], 123).as(String)

        val.should eq("123")
      end

      it "should handle multiple arguments" do
        rt = Duktape::Runtime.new do |sbx|
          sbx.eval!("function t(a, b, c) { return a + b + c; }")
        end

        val = rt.call(["t"], 2, 3, 4)

        val.should eq(9)
        val.should be_a(Float64)
      end

      it "should return nil for the empty array" do
        rt = Duktape::Runtime.new
        val = rt.call([] of String, 123)

        val.should be_nil
      end

      it "should work without any arguments passed" do
        rt = Duktape::Runtime.new
        val = rt.call(["Math", "E"]).as(Float64)

        val.floor.should eq(2)
      end

      it "should raise a Duktape::TypeError if an error was thrown" do
        rt = Duktape::Runtime.new

        expect_raises(Duktape::TypeError, TYPE_REGEX) do
          rt.call(["JSON", "invalid"], 123)
        end
      end

      it "should have an empty stack after the call" do
        rt = Duktape::Runtime.new
        val = rt.call(["Math", "sqrt"], 9)

        val.should eq(3)
        rt.ctx.get_top.should eq(0)
      end
    end

    context "fix: https://github.com/jessedoyle/duktape.cr/issues/57", tags: "bugfix" do
      it "calls functions when no arguments are provided" do
        rt = Duktape::Runtime.new do |sbx|
          sbx.eval! <<-JS
            var called = false

            function test() {
              called = true;
              return called;
            }
          JS
        end

        rt.call("test")
        result = rt.call("called")

        result.should be_true
      end
    end
  end

  describe "eval" do
    it "should return the last value evaluated" do
      rt = Duktape::Runtime.new do |sbx|
        sbx.eval!("; function bool() { return true; }")
      end

      val = rt.eval("bool();")

      val.should be_true
      val.should be_a(Bool)
    end

    it "should return a float evaluated" do
      rt = Duktape::Runtime.new
      val = rt.eval("1 + 1;")

      val.should eq(2.0)
      val.should be_a(Float64)
    end

    it "should raise a ReferenceError on invalid syntax" do
      rt = Duktape::Runtime.new

      expect_raises(Duktape::ReferenceError, REFERENCE_REGEX) do
        rt.eval("__abc__;")
      end
    end

    it "should have an empty stack after evaluation" do
      rt = Duktape::Runtime.new
      rt.eval("2 + 2;")

      rt.ctx.get_top.should eq(0)
    end
  end

  describe "exec" do
    it "should return nil for all evaluation" do
      rt = Duktape::Runtime.new
      val = rt.exec("1 + 1")

      val.should be_nil
    end

    it "should execute code" do
      rt = Duktape::Runtime.new do |sbx|
        sbx.eval!("var a = 1; function add() { a = a + 1; }")
      end

      val = rt.exec("add();")
      after = rt.eval("a;")

      val.should be_nil
      after.should be_a(Float64)
      after.should eq(2)
    end

    it "should raise on invalid syntax" do
      rt = Duktape::Runtime.new

      expect_raises(Duktape::SyntaxError, SYNTAX_REGEX) do
        rt.exec("\"missing")
      end
    end

    it "should have an empty stack after execution" do
      rt = Duktape::Runtime.new
      rt.exec("2 + 2;")

      rt.ctx.get_top.should eq(0)
    end
  end
end
