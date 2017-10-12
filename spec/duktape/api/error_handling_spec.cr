require "../../spec_helper"

describe Duktape::API::ErrorHandling do
  # Note: Can't really test this from a proc as
  # `push_proc` doesn't get along with Crystal's
  # spec library.
  describe "error" do
    it "should call the fatal handler (uncaught)" do
      ctx = Duktape::Context.new

      expect_raises Duktape::InternalError, /uncaught/ do
        ctx.error 6, "test"
      end
    end
  end

  describe "get_error_code" do
    it "should return LibDUK::Err::None on invalid index" do
      ctx = Duktape::Context.new

      ctx.get_error_code(-1).should eq(LibDUK::Err::None)
    end

    it "should get the code of an error on stack" do
      ctx = Duktape::Context.new
      ctx.push_error_object LibDUK::Err::UriError, "this is a test"
      code = ctx.get_error_code -1

      code.should eq(LibDUK::Err::UriError)
    end
  end

  describe "is_error" do
    it "should return true when element is an error object" do
      ctx = Duktape::Context.new
      ctx.push_error_object 56, "test"

      ctx.is_error(-1).should be_true
    end

    it "should return false when not an error" do
      ctx = Duktape::Context.new
      ctx << "test"

      ctx.is_error(-1).should be_false
    end
  end

  describe "is_error?" do
    it "should return true if the value is an error" do
      ctx = Duktape::Context.new
      ctx.push_error_object LibDUK::Err::UriError, "msg"
      val = ctx.is_error?(-1)

      val.should be_true
    end

    it "should return false if value is not an error" do
      ctx = Duktape::Context.new
      ctx << "not error"
      val = ctx.is_error?(-1)

      val.should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_error(-1).should be_false
    end
  end

  describe "raise_error" do
    it "should not raise and return 0 when not given an argument" do
      ctx = Duktape::Context.new
      val = ctx.raise_error

      val.should eq(0)
    end

    it "should rescue with a Duktape::Error" do
      ctx = Duktape::Context.new
      ctx.push_error_object LibDUK::Err::Error, "test"

      begin
        ctx.raise_error(-1)
        # We should not get this far due to a raise
        1.should_not eq(1)
      rescue ex : Duktape::Error
        1.should eq(1)
      end
    end

    it "should raise a Duktape::Error" do
      ctx = Duktape::Context.new
      ctx.push_error_object LibDUK::Err::Error, "test"

      expect_raises Duktape::Error, /test/ do
        ctx.raise_error(-1)
      end
    end

    it "should raise a Duktape::EvalError" do
      ctx = Duktape::Context.new
      ctx.push_error_object LibDUK::Err::EvalError, "test"

      expect_raises Duktape::EvalError, /test/ do
        ctx.raise_error(-1)
      end
    end

    it "should raise a Duktape::RangeError" do
      ctx = Duktape::Context.new
      ctx.push_error_object LibDUK::Err::RangeError, "test"

      expect_raises Duktape::RangeError, /test/ do
        ctx.raise_error(-1)
      end
    end

    it "should raise a Duktape::ReferenceError" do
      ctx = Duktape::Context.new
      ctx.push_error_object LibDUK::Err::ReferenceError, "test"

      expect_raises Duktape::ReferenceError, /test/ do
        ctx.raise_error(-1)
      end
    end

    it "should raise a Duktape::SyntaxError" do
      ctx = Duktape::Context.new
      ctx.push_error_object LibDUK::Err::SyntaxError, "test"

      expect_raises Duktape::SyntaxError, /test/ do
        ctx.raise_error(-1)
      end
    end

    it "should raise a Duktape::TypeError" do
      ctx = Duktape::Context.new
      ctx.push_error_object LibDUK::Err::TypeError, "test"

      expect_raises Duktape::TypeError, /test/ do
        ctx.raise_error(-1)
      end
    end

    it "should raise a Duktape::URIError" do
      ctx = Duktape::Context.new
      ctx.push_error_object LibDUK::Err::UriError, "test"

      expect_raises Duktape::URIError, /test/ do
        ctx.raise_error(-1)
      end
    end
  end

  # Note: Can't really test this from a proc as
  # `push_proc` doesn't get along with Crystal's
  # spec library.
  describe "throw" do
    it "should call the fatal handler (uncaught)" do
      ctx = Duktape::Context.new
      ctx << "error!"

      expect_raises Duktape::InternalError, /uncaught/ do
        ctx.throw
      end
    end
  end
end
