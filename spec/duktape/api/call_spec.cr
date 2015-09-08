require "../../spec_helper"

describe Duktape::API::Call do
  describe "call" do
    it "should raise if nargs < 0" do
      ctx = Duktape::Context.new

      expect_raises Duktape::Error, /negative argument/ do
        ctx.call(-1)
      end
    end

    it "should raise when too few args" do
      ctx = Duktape::Context.new
      ctx.push_proc do |ptr|
        env = Duktape::Context.new ptr
        env.push_int 42
        env.return 1
      end

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.call 2
      end
    end

    it "should call a function" do
      ctx = Duktape::Context.new
      ctx.push_proc do |ptr|
        env = Duktape::Context.new ptr
        env.push_int 42
        env.return 1
      end
      ctx.call 0
      num = ctx.get_int -1

      num.should eq(42)
    end
  end

  describe "call_method" do
    it "should call a method from stack" do
      ctx = Duktape::Context.new
      ctx.compile! <<-JS
        var a = function(x, y){
          return x + y;
        };
      JS
      ctx << 123
      ctx << 4
      ctx << 6
      val = ctx.call_method 2

      val.should be_true
    end

    it "should raise if nargs < 0" do
      ctx = Duktape::Context.new

      expect_raises Duktape::Error, /negative argument/ do
        ctx.call_method -1
      end
    end

    it "should raise if stack is empty" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.call_method 0
      end
    end
  end

  describe "call_prop" do
    it "calls a function as a property" do
      ctx = Duktape::Context.new
      ctx << 12345
      ctx.to_object -1
      ctx << "toString"
      ctx << 16
      val = ctx.call_prop -3, 1
      str = ctx.get_string -1

      val.should be_true
      str.should eq("3039")
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.call_prop -1, 0
      end
    end
  end

  describe "new" do
    it "should call the constructor" do
      # JS: new String("test string");
      ctx = Duktape::Context.new
      ctx.push_global_object
      ctx << "String"
      ctx.get_prop -2
      ctx << "test string"
      ctx.new 1

      ctx.to_string(-1).should eq("test string")
    end

    it "should raise on negative nargs" do
      ctx = Duktape::Context.new

      expect_raises Duktape::Error, /negative argument/ do
        ctx.new -1
      end
    end
  end

  describe "return" do
    it "should implcitly return the int provided" do
      ctx = Duktape::Context.new
      num = ctx.return 42

      num.should eq(42)
    end
  end
end
