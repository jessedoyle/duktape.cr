require "../../spec_helper"

describe Duktape::API::Pop do
  describe "pop" do
    it "should pop a single value from the stack" do
      ctx = Duktape::Context.new
      ctx << "123"
      top_with_str = ctx.get_top
      ctx.pop
      top_popped = ctx.get_top

      top_with_str.should eq(1)
      top_popped.should eq(0)
    end

    it "should raise StackError if empty" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /stack empty/ do
        ctx.pop
      end
    end
  end

  describe "pop_2" do
    it "should pop 2 elements from the stack" do
      ctx = Duktape::Context.new
      ctx << 1
      ctx << 2
      before = ctx.get_top
      ctx.pop_2
      after = ctx.get_top

      before.should eq(2)
      after.should eq(0)
    end

    it "should raise if there are not 2 elements" do
      ctx = Duktape::Context.new
      ctx << 1

      expect_raises Duktape::StackError, /stack empty/ do
        ctx.pop_2
      end
    end
  end

  describe "pop_3" do
    it "should pop 3 elements from the stack" do
      ctx = Duktape::Context.new
      ctx << 1
      ctx << 2
      ctx << 3
      before = ctx.get_top
      ctx.pop_3
      after = ctx.get_top

      before.should eq(3)
      after.should eq(0)
    end

    it "should raise if there are less than 3 elements" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /stack empty/ do
        ctx.pop_3
      end
    end
  end

  describe "pop_n" do
    it "should pop n elements from the stack" do
      ctx = Duktape::Context.new
      ctx << 1
      ctx << 2
      ctx << 3
      ctx << 4
      before = ctx.get_top
      ctx.pop_n 4
      after = ctx.get_top

      before.should eq(4)
      after.should eq(0)
    end

    it "should raise when n is negative" do
      ctx = Duktape::Context.new

      expect_raises Duktape::Error, /negative count/ do
        ctx.pop_n -1
      end
    end

    it "should raise when there are less than n elements" do
      ctx = Duktape::Context.new
      ctx << 1

      expect_raises Duktape::StackError, /stack empty/ do
        ctx.pop_n 20
      end
    end
  end
end
