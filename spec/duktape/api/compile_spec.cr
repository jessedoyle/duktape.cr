require "../../spec_helper"

describe Duktape::API::Compile do
  valid_js = <<-JS
    function func(a, b){
      return a + b;
    }
  JS

  invalid_js = <<-JS
    var syntax_error_here=
  JS

  describe "compile" do
    context "without string arg" do
      it "should compile js source on stack and return 0" do
        ctx = Duktape::Context.new
        ctx << valid_js
        ctx << "test.js"
        val = ctx.compile
        top = ctx.is_function -1

        val.should eq(0)
        top.should be_true
      end

      it "should not raise on invalid js and return non-zero" do
        ctx = Duktape::Context.new
        ctx << invalid_js
        ctx << "invalid.js"
        val = ctx.compile
        err = ctx.safe_to_string -1

        val.should_not eq(0)
        err.should match(/SyntaxError/)
      end

      it "should raise if there are not 2 arguments on the stack" do
        ctx = Duktape::Context.new
        ctx << valid_js

        expect_raises Duktape::StackError, /invalid index/ do
          ctx.compile
        end
      end
    end

    context "with string arg" do
      it "should compile valid js source from arg" do
        ctx = Duktape::Context.new
        err = ctx.compile "var a = 10;"
        val = ctx.is_function -1

        err.should eq(0)
        val.should be_true
      end

      it "should return non-zero on invalid js" do
        ctx = Duktape::Context.new
        val = ctx.compile invalid_js
        err = ctx.safe_to_string -1

        val.should_not eq(0)
        err.should match(/SyntaxError/)
      end
    end
  end

  describe "compile!" do
    context "without string arg" do
      it "should compile valid js and return 0" do
        ctx = Duktape::Context.new
        ctx << valid_js
        ctx << "test.js"
        val = ctx.compile!
        func = ctx.is_function(-1)

        val.should eq(0)
        func.should be_true
      end

      it "should raise on invalid js" do
        ctx = Duktape::Context.new
        ctx << invalid_js
        ctx << "invalid.js"

        expect_raises Duktape::SyntaxError, /parse error/ do
          ctx.compile!
        end
      end
    end

    context "with string arg" do
      it "should compile valid js from arg and return 0" do
        ctx = Duktape::Context.new
        val = ctx.compile! valid_js
        top = ctx.is_function -1

        val.should eq(0)
        top.should be_true
      end

      it "should raise when provided invalid js" do
        ctx = Duktape::Context.new

        expect_raises Duktape::SyntaxError, /parse error/ do
          ctx.compile! invalid_js
        end
      end
    end
  end

  describe "compile_file" do
    it "should raise on invalid file" do
      ctx = Duktape::Context.new

      expect_raises Duktape::FileError, /invalid file/ do
        ctx.compile_file "__invalid.js"
      end
    end

    it "should compile valid js from a file" do
      ctx = Duktape::Context.new
      val = ctx.compile_file "#{JS_SOURCE_PATH}/valid.js"
      top = ctx.is_function -1

      val.should eq(0)
      top.should be_true
    end

    it "should return non-zero on invalid js file" do
      ctx = Duktape::Context.new
      val = ctx.compile_file "#{JS_SOURCE_PATH}/invalid.js"
      err = ctx.safe_to_string -1

      val.should_not eq(0)
      err.should match(/SyntaxError/)
    end
  end

  describe "compile_file!" do
    it "should raise on invalid file" do
      ctx = Duktape::Context.new

      expect_raises Duktape::FileError, /invalid file/ do
        ctx.compile_file! "__invalid.js"
      end
    end

    it "should compile valid js from a file" do
      ctx = Duktape::Context.new
      val = ctx.compile_file! "#{JS_SOURCE_PATH}/valid.js"
      top = ctx.is_function -1

      val.should eq(0)
      top.should be_true
    end

    it "should raise on invalid js" do
      ctx = Duktape::Context.new

      expect_raises Duktape::SyntaxError, /unterminated string/ do
        ctx.compile_file! "#{JS_SOURCE_PATH}/invalid.js"
      end
    end
  end

  describe "compile_lstring" do
    it "should compile a valid string with length" do
      ctx = Duktape::Context.new
      val = ctx.compile_lstring valid_js, valid_js.size

      ctx.is_function(-1).should be_true
      val.should eq(0)
    end

    it "should return non-zero on invalid lstring" do
      ctx = Duktape::Context.new
      val = ctx.compile_lstring invalid_js, invalid_js.size

      ctx.safe_to_string(-1).should match(/SyntaxError/)
      val.should_not eq(0)
    end
  end

  describe "compile_lstring!" do
    it "should compile a valid string with length" do
      ctx = Duktape::Context.new
      val = ctx.compile_lstring! valid_js, valid_js.size

      ctx.is_function(-1).should be_true
      val.should eq(0)
    end

    it "should raise on invalid js" do
      ctx = Duktape::Context.new

      expect_raises Duktape::SyntaxError, /parse error/ do
        ctx.compile_lstring! invalid_js, invalid_js.size
      end
    end
  end

  describe "compile_lstring_filename" do
    it "should raise on empty stack" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.compile_lstring_filename valid_js, valid_js.size
      end
    end

    it "should compile a valid js file" do
      ctx = Duktape::Context.new
      ctx << "test.js"
      err = ctx.compile_lstring_filename valid_js, valid_js.size

      err.should eq(0)
      ctx.is_function(-1).should be_true
    end

    it "should return non-zero on invalid js" do
      ctx = Duktape::Context.new
      ctx << "test.js"
      err = ctx.compile_lstring_filename invalid_js, invalid_js.size
      str = ctx.safe_to_string -1

      err.should_not eq(0)
      str.should match(/SyntaxError/)
    end
  end

  describe "compile_lstring_filename!" do
    it "should raise on empty stack" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.compile_lstring_filename! valid_js, valid_js.size
      end
    end

    it "should compile a valid js file" do
      ctx = Duktape::Context.new
      ctx << "test.js"
      err = ctx.compile_lstring_filename! valid_js, valid_js.size

      err.should eq(0)
      ctx.is_function(-1).should be_true
    end

    it "should raise on invalid js" do
      ctx = Duktape::Context.new
      ctx << "test.js"

      expect_raises Duktape::SyntaxError, /parse error/ do
        ctx.compile_lstring_filename! invalid_js, invalid_js.size
      end
    end
  end

  describe "compile_string" do
    it "should compile valid js string" do
      ctx = Duktape::Context.new
      err = ctx.compile_string "var a = 10;"
      val = ctx.is_function -1

      err.should eq(0)
      val.should be_true
    end

    it "should return non-zero on invalid js" do
      ctx = Duktape::Context.new
      val = ctx.compile_string invalid_js
      err = ctx.safe_to_string -1

      val.should_not eq(0)
      err.should match(/SyntaxError/)
    end
  end

  describe "compile_string!" do
    it "should compile valid js string" do
      ctx = Duktape::Context.new
      err = ctx.compile_string! "var a = 10;"
      val = ctx.is_function -1

      err.should eq(0)
      val.should be_true
    end

    it "should raise on invalid js" do
      ctx = Duktape::Context.new

      expect_raises Duktape::SyntaxError, /parse error/ do
        ctx.compile_string! invalid_js
      end
    end
  end

  describe "compile_string_filename" do
    it "should raise on empty stack" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.compile_string_filename valid_js
      end
    end

    it "should compile valid js string" do
      ctx = Duktape::Context.new
      ctx << "file.js"
      err = ctx.compile_string_filename "var a = 10;"
      val = ctx.is_function -1

      err.should eq(0)
      val.should be_true
    end

    it "should return non-zero on invalid js" do
      ctx = Duktape::Context.new
      ctx << "file.js"
      val = ctx.compile_string_filename invalid_js
      err = ctx.safe_to_string -1

      val.should_not eq(0)
      err.should match(/SyntaxError/)
    end
  end

  describe "compile_string_filename!" do
    it "should compile a valid js string" do
      ctx = Duktape::Context.new
      ctx << "test.js"
      err = ctx.compile_string_filename! valid_js

      ctx.is_function(-1).should be_true
      err.should eq(0)
    end

    it "should raise on invalid js" do
      ctx = Duktape::Context.new
      ctx << "invalid.js"

      expect_raises Duktape::SyntaxError, /parse error/ do
        ctx.compile_string_filename! invalid_js
      end
    end

    it "should raise on empty stack" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.compile_string_filename valid_js
      end
    end
  end

  describe "dump_function" do
    it "should dump a buffer containing function bytecode" do
      ctx = Duktape::Context.new
      ctx.eval <<-JS
        (function helloWorld() { print('hello world'); })
      JS
      ctx.dump_function

      last_stack_type(ctx).should be_js_type(:buffer)
    end
  end

  describe "load_function" do
    it "should load bytecode from a buffer" do
      ctx = Duktape::Context.new
      ctx.eval <<-JS
        (function helloWorld() { print('hello world'); })
      JS
      ctx.dump_function
      ctx.load_function

      last_stack_type(ctx).should be_js_type(:object)
    end

    it "should raise if stack top is not buffer" do
      ctx = Duktape::Context.new
      ctx << 1

      expect_raises Duktape::TypeError, /not buffer/ do
        ctx.load_function
      end
    end

    it "should raise if stack is empty" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.load_function
      end
    end
  end
end
