require "../../spec_helper"

describe Duktape::API::Eval do
  valid_js = <<-JS
    var sum = 0;
    for (var i = 0; i < 10; i++){
      sum += i;
    }
  JS

  invalid_js = <<-JS
    __invalid_identifier();
  JS

  describe "eval" do
    context "with string argument" do
      it "should eval the string as js code" do
        ctx = Duktape::Context.new
        err = ctx.eval valid_js

        err.should eq(0)
      end
    end

    context "without string argument" do
      it "evaluates valid js code from the stack" do
        ctx = Duktape::Context.new
        ctx << valid_js
        err = ctx.eval

        err.should eq(0)
      end

      it "returns non-zero when running invalid js" do
        ctx = Duktape::Context.new
        ctx << invalid_js
        err = ctx.eval

        err.should_not eq(0)
      end
    end
  end

  describe "eval!" do
    context "with string argument" do
      it "should eval argument as js code" do
        ctx = Duktape::Context.new
        err = ctx.eval! valid_js

        err.should eq(0)
      end

      it "should raise if arg contains invalid js" do
        ctx = Duktape::Context.new

        expect_raises Duktape::ReferenceError, /identifier '__invalid_identifier' undefined/ do
          ctx.eval! invalid_js
        end
      end
    end

    context "without string argument" do
      it "should return 0 if valid js" do
        ctx = Duktape::Context.new
        ctx << valid_js
        err = ctx.eval!

        err.should eq(0)
      end

      it "should raise an error on invalid js" do
        ctx = Duktape::Context.new
        ctx << invalid_js

        expect_raises Duktape::ReferenceError, /identifier '__invalid_identifier' undefined/ do
          ctx.eval!
        end
      end
    end
  end

  describe "eval_file" do
    it "should evaluate a valid js file" do
      ctx = Duktape::Context.new
      err = ctx.eval_file "#{JS_SOURCE_PATH}/valid.js"

      err.should eq(0)
    end

    it "should return non-zero on file containing invalid js" do
      ctx = Duktape::Context.new
      err = ctx.eval_file "#{JS_SOURCE_PATH}/invalid.js"

      err.should_not eq(0)
    end

    it "should raise on invalid file" do
      ctx = Duktape::Context.new

      expect_raises Duktape::FileError, /invalid file/ do
        ctx.eval_file "__invalid.js"
      end
    end
  end

  describe "eval_file!" do
    it "should return 0 if file contains valid js" do
      ctx = Duktape::Context.new
      err = ctx.eval_file! "#{JS_SOURCE_PATH}/valid.js"

      err.should eq(0)
    end

    it "should raise an error on invalid js" do
      ctx = Duktape::Context.new

      expect_raises Duktape::SyntaxError, /unterminated string/ do
        ctx.eval_file! "#{JS_SOURCE_PATH}/invalid.js"
      end
    end
  end

  describe "eval_file_noresult" do
    it "should evaluate valid js without leaving a stack value" do
      ctx = Duktape::Context.new
      err = ctx.eval_file_noresult "#{JS_SOURCE_PATH}/valid.js"

      last_stack_type(ctx).should be_js_type(:none)
      err.should eq(0)
    end

    it "should raise on invalid file" do
      ctx = Duktape::Context.new

      expect_raises Duktape::FileError, /invalid file/ do
        ctx.eval_file_noresult "__invalid.js"
      end
    end
  end

  describe "eval_file_noresult!" do
    it "should return 0 on valid js" do
      ctx = Duktape::Context.new
      err = ctx.eval_file_noresult! "#{JS_SOURCE_PATH}/valid.js"

      last_stack_type(ctx).should be_js_type(:none)
      err.should eq(0)
    end

    it "should raise an error on invalid js" do
      ctx = Duktape::Context.new

      # Because the NORESULT flag tells Duktape to
      # not push the Error object on the stack after
      # failure, we have to look for a StackError
      expect_raises Duktape::StackError, /stack empty/ do
        ctx.eval_file_noresult! "#{JS_SOURCE_PATH}/invalid.js"
      end
    end
  end

  describe "eval_lstring" do
    it "should evaluate a valid js string and length" do
      ctx = Duktape::Context.new
      err = ctx.eval_lstring valid_js, valid_js.size

      err.should eq(0)
    end

    it "should return Err::Error if length < 0" do
      ctx = Duktape::Context.new
      err = ctx.eval_lstring valid_js, -1

      err.should eq(LibDUK::Err::Error)
    end
  end

  describe "eval_lstring!" do
    it "should return 0 on valid js" do
      ctx = Duktape::Context.new
      err = ctx.eval_lstring! valid_js, valid_js.size

      err.should eq(0)
    end

    it "should raise an error on invalid js" do
      ctx = Duktape::Context.new

      expect_raises Duktape::ReferenceError, /identifier '__invalid_identifier' undefined/ do
        ctx.eval_lstring! invalid_js, invalid_js.size
      end
    end

    it "should raise when length is negative" do
      ctx = Duktape::Context.new

      expect_raises ArgumentError, /negative string length/ do
        ctx.eval_lstring! valid_js, -1
      end
    end
  end

  describe "eval_lstring_noresult" do
    it "should evaluate valid js without leaving a stack value" do
      ctx = Duktape::Context.new
      err = ctx.eval_lstring_noresult valid_js, valid_js.size

      err.should eq(0)
      last_stack_type(ctx).should be_js_type(:none)
    end

    it "should not leave an error on stack for invalid js" do
      ctx = Duktape::Context.new
      err = ctx.eval_lstring_noresult invalid_js, invalid_js.size

      err.should_not eq(0)
      last_stack_type(ctx).should be_js_type(:none)
    end

    it "should return Err::Error if length < 0" do
      ctx = Duktape::Context.new
      err = ctx.eval_lstring_noresult valid_js, -1

      err.should eq(LibDUK::Err::Error)
    end
  end

  describe "eval_lstring_noresult!" do
    it "should return 0 on valid js" do
      ctx = Duktape::Context.new
      err = ctx.eval_lstring_noresult! valid_js, valid_js.size

      err.should eq(0)
    end

    it "should raise on invalid js" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /stack empty/ do
        ctx.eval_lstring_noresult! invalid_js, invalid_js.size
      end
    end

    it "should raise when length is negative" do
      ctx = Duktape::Context.new

      expect_raises ArgumentError, /negative string length/ do
        ctx.eval_lstring_noresult! valid_js, -1
      end
    end
  end

  describe "eval_noresult" do
    it "should eval valid js without result on stack" do
      ctx = Duktape::Context.new
      ctx << valid_js
      err = ctx.eval_noresult

      err.should eq(0)
    end

    it "should return non-zero on invalid js" do
      ctx = Duktape::Context.new
      ctx << invalid_js
      err = ctx.eval_noresult

      err.should_not eq(0)
      last_stack_type(ctx).should be_js_type(:none)
    end
  end

  describe "eval_noresult!" do
    it "should return 0 on valid js" do
      ctx = Duktape::Context.new
      ctx << valid_js
      err = ctx.eval_noresult!

      err.should eq(0)
    end

    it "should raise on invalid js without result on stack" do
      ctx = Duktape::Context.new
      ctx << invalid_js

      expect_raises Duktape::StackError, /stack empty/ do
        ctx.eval_noresult!
      end
    end

    it "should eval valid js with no result on stack" do
      ctx = Duktape::Context.new
      ctx << valid_js
      ctx.eval_noresult!

      last_stack_type(ctx).should be_js_type(:none)
    end
  end

  describe "eval_string" do
    it "should eval a valid js string" do
      ctx = Duktape::Context.new
      err = ctx.eval_string valid_js

      err.should eq(0)
      last_stack_type(ctx).should be_js_type(:number)
    end

    it "should return non-zero on invalid js string" do
      ctx = Duktape::Context.new
      err = ctx.eval_string invalid_js

      err.should_not eq(0)
      # Error object left on stack
      last_stack_type(ctx).should be_js_type(:object)
    end
  end

  describe "eval_string!" do
    it "should raise on invalid js strings" do
      ctx = Duktape::Context.new

      expect_raises Duktape::ReferenceError, /identifier '__invalid_identifier' undefined/ do
        ctx.eval_string! invalid_js
      end
    end

    it "should eval valid js strings" do
      ctx = Duktape::Context.new
      ctx.eval_string! valid_js

      last_stack_type(ctx).should be_js_type(:number)
    end

    it "should return 0 on valid js" do
      ctx = Duktape::Context.new
      err = ctx.eval_string! valid_js

      err.should eq(0)
    end
  end

  describe "eval_string_noresult" do
    it "should eval valid js strings with no stack result" do
      ctx = Duktape::Context.new
      err = ctx.eval_string_noresult valid_js

      err.should eq(0)
      last_stack_type(ctx).should be_js_type(:none)
    end

    it "should not leave error on stack if invalid" do
      ctx = Duktape::Context.new
      err = ctx.eval_string_noresult invalid_js

      err.should_not eq(0)
      last_stack_type(ctx).should be_js_type(:none)
    end
  end

  describe "eval_string_noresult!" do
    it "should raise StackError on invalid js" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /stack empty/ do
        ctx.eval_string_noresult! invalid_js
      end
    end

    it "should return 0 on valid js" do
      ctx = Duktape::Context.new
      err = ctx.eval_string_noresult! valid_js

      err.should eq(0)
    end

    it "should leave no stack return valid when valid" do
      ctx = Duktape::Context.new
      ctx.eval_string_noresult! valid_js

      last_stack_type(ctx).should be_js_type(:none)
    end
  end
end
