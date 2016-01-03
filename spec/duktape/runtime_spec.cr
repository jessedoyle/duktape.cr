require "../spec_helper"
require "../../src/duktape/runtime"

describe Duktape::Runtime do
  describe "initialize" do
    context "without arguments" do
      it "should create a Runtime instance" do
        rt = Duktape::Runtime.new

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
      end
    end
  end

  describe "call" do
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
        val = rt.call("Math.PI") as Float64

        val.should_not be_nil
        val.floor.should eq(3)
      end
    end

    context "with multiple property names" do
      it "should call the nested property with arguments" do
        rt = Duktape::Runtime.new
        val = rt.call(["JSON", "stringify"], 123) as String

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
        val = rt.call(["Math", "E"]) as Float64

        val.floor.should eq(2)
      end

      it "should return a ComplexObject on error" do
        rt = Duktape::Runtime.new
        val = rt.call(["JSON", "invalid"], 123) as Duktape::Runtime::ComplexObject

        val.should be_a(Duktape::Runtime::ComplexObject)
        val.string.should eq("TypeError: not callable")
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

      expect_raises(Duktape::Error, /ReferenceError/) do
        rt.eval("__abc__;")
      end
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

      expect_raises(Duktape::Error, /SyntaxError/) do
        rt.exec("\"missing")
      end
    end
  end
end
