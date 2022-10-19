require "../../spec_helper"

describe Duktape::API::Coercion do
  describe "buffer_to_string" do
    it "should coerce a buffer to a string" do
      ctx = Duktape::Context.new
      ctx << "a string buffer"
      ctx.to_buffer -1
      str = ctx.buffer_to_string -1

      str.should eq("a string buffer")
    end

    it "should raise TypeError when index is not a buffer" do
      ctx = Duktape::Context.new
      ctx << "not a buffer"

      expect_raises Duktape::TypeError, /is not buffer/ do
        ctx.buffer_to_string -1
      end
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.buffer_to_string -1
      end
    end
  end

  describe "safe_to_lstring" do
    it "should safely coerce values to strings (returning tuple)" do
      ctx = Duktape::Context.new
      ctx.eval_string <<-JS
        ({ toString: function() { throw new Error('toString error'); } });
      JS
      tup = ctx.safe_to_lstring -1

      tup.should be_a(Tuple(String, UInt64))
      tup[0].should eq("Error: toString error")
      tup[1].should eq(21)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.safe_to_lstring -1
      end
    end
  end

  describe "safe_to_stacktrace" do
    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.safe_to_stacktrace -1
      end
    end

    it "stringifies the stack of error objects" do
      ctx = Duktape::Context.new
      ctx.eval "1 + 2 +" # SyntaxError
      trace = ctx.safe_to_stacktrace(-1)

      trace.should match(/SyntaxError: parse error/)
    end
  end

  describe "safe_to_string" do
    it "should safely coerce values to strings" do
      ctx = Duktape::Context.new
      ctx.eval_string <<-JS
        ({ toString: function() { throw new Error('toString error'); } });
      JS
      str = ctx.safe_to_string -1

      str.should eq("Error: toString error")
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.safe_to_string -1
      end
    end
  end

  describe "to_boolean" do
    it "should return a boolean value" do
      ctx = Duktape::Context.new
      ctx << "coerced to bool"
      val = ctx.to_boolean -1

      val.should be_true
      last_stack_type(ctx).should be_js_type(:boolean)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_boolean -1
      end
    end
  end

  describe "to_buffer" do
    it "should return a Slice(UInt8)" do
      ctx = Duktape::Context.new
      ctx << 123.456
      buf = ctx.to_buffer -1

      buf.should be_a(Slice(UInt8))
      last_stack_type(ctx).should be_js_type(:buffer)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_buffer -1
      end
    end
  end

  describe "to_dynamic_buffer" do
    it "should coerce the target to a dynamic buffer" do
      ctx = Duktape::Context.new
      ctx << "abcd"
      buf = ctx.to_dynamic_buffer -1

      buf.should be_a(Slice(UInt8))
      ctx.is_dynamic_buffer(-1).should be_true
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_dynamic_buffer -1
      end
    end
  end

  describe "to_fixed_buffer" do
    it "should coerce the target to a static buffer" do
      ctx = Duktape::Context.new
      ctx << "abcd"
      buf = ctx.to_fixed_buffer -1

      buf.should be_a(Slice(UInt8))
      ctx.is_dynamic_buffer(-1).should be_false
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_fixed_buffer -1
      end
    end
  end

  describe "to_int" do
    it "should coerce the target to an int32" do
      ctx = Duktape::Context.new
      ctx << "string"
      val = ctx.to_int -1

      val.should be_a(Int32)
      val.should eq(0)
      last_stack_type(ctx).should be_js_type(:number)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_int -1
      end
    end
  end

  describe "to_int32" do
    it "should coerce the target to an int32" do
      ctx = Duktape::Context.new
      ctx << 123.456
      val = ctx.to_int32 -1

      val.should be_a(Int32)
      val.should eq(123)
      last_stack_type(ctx).should be_js_type(:number)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_int32 -1
      end
    end
  end

  describe "to_lstring" do
    it "should coerce the target to a string and return Tuple(String, Int)" do
      ctx = Duktape::Context.new
      ctx << 123.456
      tup = ctx.to_lstring -1

      tup.should be_a(Tuple(String, UInt64))
      tup[0].should eq("123.456")
      tup[1].should eq(7)
      last_stack_type(ctx).should be_js_type(:string)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_lstring -1
      end
    end
  end

  describe "to_null" do
    it "should coerce the target to null" do
      ctx = Duktape::Context.new
      ctx << "not null"
      ctx.to_null -1

      last_stack_type(ctx).should be_js_type(:null)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_null -1
      end
    end
  end

  describe "to_number" do
    it "should coerce the target to a number and return Float64" do
      ctx = Duktape::Context.new
      ctx << "not number"
      val = ctx.to_number -1

      val.nan?.should be_true
      val.should be_a(Float64)
      last_stack_type(ctx).should be_js_type(:number)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_number -1
      end
    end
  end

  describe "to_object" do
    it "should coerce the target to object" do
      ctx = Duktape::Context.new
      ctx << "a string"
      ctx.to_object -1

      last_stack_type(ctx).should be_js_type(:object)
    end

    it "should raise when target not object coercible" do
      ctx = Duktape::Context.new
      ctx.push_null

      expect_raises Duktape::TypeError, /not object/ do
        ctx.to_object -1
      end
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_object -1
      end
    end
  end

  describe "to_pointer" do
    it "should coerce target to a pointer" do
      ctx = Duktape::Context.new
      ctx << "pointer"
      ptr = ctx.to_pointer -1

      ptr.class.should eq(Pointer(Void))
      last_stack_type(ctx).should be_js_type(:pointer)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_pointer -1
      end
    end
  end

  describe "to_primitive" do
    it "should replace target with a ToPrimitive() call" do
      ctx = Duktape::Context.new
      ctx << true
      ctx.to_primitive -1

      last_stack_type(ctx).should be_js_type(:boolean)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_primitive -1
      end
    end
  end

  describe "to_stacktrace" do
    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_stacktrace -1
      end
    end

    it "stringifies an error object stack" do
      ctx = Duktape::Context.new
      ctx.push_error_object LibDUK::Err::Error, "TEST"
      trace = ctx.to_stacktrace -1

      trace.should match(/Error: TEST.*at \[anon\]/m)
    end

    it "stringifies a non-error object" do
      ctx = Duktape::Context.new
      ctx << true
      trace = ctx.to_stacktrace -1

      trace.should eq("true")
    end
  end

  describe "to_string" do
    it "should coerce the target to a string" do
      ctx = Duktape::Context.new
      ctx << true
      val = ctx.to_string -1

      val.should eq("true")
      last_stack_type(ctx).should be_js_type(:string)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_string -1
      end
    end
  end

  describe "to_uint" do
    it "should coerce the target to number" do
      ctx = Duktape::Context.new
      ctx << -123
      val = ctx.to_uint -1

      val.should be_a(UInt32)
      val.should eq(0)
      last_stack_type(ctx).should be_js_type(:number)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_uint -1
      end
    end
  end

  describe "to_uint16" do
    it "should coerce the target to number" do
      ctx = Duktape::Context.new
      ctx << 1
      val = ctx.to_uint16 -1

      val.should be_a(UInt16)
      val.should eq(1)
      last_stack_type(ctx).should be_js_type(:number)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_uint16 -1
      end
    end
  end

  describe "to_uint32" do
    it "should coerce the target to number" do
      ctx = Duktape::Context.new
      ctx << 1
      val = ctx.to_uint32 -1

      val.should be_a(UInt32)
      val.should eq(1)
      last_stack_type(ctx).should be_js_type(:number)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_uint32 -1
      end
    end
  end

  describe "to_undefined" do
    it "should coerce the target to undefined" do
      ctx = Duktape::Context.new
      ctx.push_null
      ctx.to_undefined -1

      last_stack_type(ctx).should be_js_type(:undefined)
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.to_undefined -1
      end
    end
  end
end
