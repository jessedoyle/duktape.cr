require "../../spec_helper"

describe Duktape::API::ErrorHandling do
  # Note: Can't really test this from a proc as
  # `push_proc` doesn't get along with Crystal's
  # spec library.
  describe "error" do
    it "should call the fatal handler (uncaught)" do
      ctx = Duktape::Context.new

      expect_raises Duktape::InternalError, /uncaught error/ do
        ctx.error 56, "test"
      end
    end
  end

  describe "fatal" do
    it "should call the fatal handler" do
      ctx = Duktape::Context.new

      expect_raises Duktape::InternalError, /test/ do
        ctx.fatal 101, "test"
      end
    end
  end

  describe "get_error_code" do
    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.get_error_code(-1)
      end
    end

    it "should get the code of an error on stack" do
      ctx = Duktape::Context.new
      ctx.push_error_object 101, "this is a test"
      code = ctx.get_error_code -1

      code.should eq(101)
    end
  end

  describe "is_error?" do
    it "should return true if the value is an error" do
      ctx = Duktape::Context.new
      ctx.push_error_object 101, "msg"
      val = ctx.is_error?(-1)

      val.should be_true
    end

    it "should return false if value is not an error" do
      ctx = Duktape::Context.new
      ctx << "not error"
      val = ctx.is_error(-1)

      val.should be_false
    end
  end

  # Note: Can't really test this from a proc as
  # `push_proc` doesn't get along with Crystal's
  # spec library.
  describe "throw" do
    it "should call the fatal handler (uncaught)" do
      ctx = Duktape::Context.new
      ctx << "error!"

      expect_raises Duktape::InternalError, /uncaught error/ do
        ctx.throw
      end
    end
  end
end
