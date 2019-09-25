require "../../spec_helper"

# NOTE: All the following methods raise on invalid index
# using `ctx.require_valid_index`. This mechanism is
# adequately tested in `stack_spec`, so there is no need
# to test that functionality here.

describe Duktape::API::Require do
  ctx = Duktape::Context.new

  describe "require_boolean" do
    it "should return a valid boolean" do
      ctx << true
      val = ctx.require_boolean(-1)

      val.should be_true
    end

    it "should raise TypeError if not a boolean" do
      ctx << "string"

      expect_raises Duktape::TypeError, /is not boolean/ do
        ctx.require_boolean(-1)
      end
    end
  end

  describe "require_buffer" do
    it "should return a Slice(UInt8) of proper length" do
      ctx.push_buffer 2
      buf = ctx.require_buffer(-1)

      buf.class.should eq(Slice(UInt8))
      buf.size.should eq(2)
    end

    it "should raise TypeError if not a buffer" do
      ctx << "not buffer"

      expect_raises Duktape::TypeError, /is not buffer/ do
        ctx.require_buffer(-1)
      end
    end
  end

  describe "require_callable" do
    it "should not raise if the index is a function" do
      ctx.push_proc(0) do |ptr|
        env = Duktape::Context.new ptr
        env << 1 + 2
        env.return 1
      end

      ctx.require_callable(-1)

      1.should eq(1)
    end

    it "should raise TypeError if the index is not a function" do
      ctx << 1

      expect_raises(Duktape::TypeError, /is not a function/) do
        ctx.require_callable(-1)
      end
    end
  end

  describe "require_constructable" do
    it "should raise on invalid index" do
      ctx.set_top(0)

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.require_constructable -1
      end
    end

    it "raises when the function is not constructable" do
      ctx.push_undefined

      expect_raises Duktape::TypeError, /is not constructable/ do
        ctx.require_constructable -1
      end
    end
  end

  describe "require_constructor_call" do
    it "should raise when not a constructor call" do
      expect_raises Duktape::TypeError, /is not a constructor call/ do
        ctx.require_constructor_call
      end
    end
  end

  describe "require_context" do
    it "should return a Duktape::Context when valid" do
      ctx.push_thread
      thr = ctx.require_context(-1)

      thr.should be_a(Duktape::Context)
    end

    it "should raise TypeError if not a thread" do
      ctx << 1

      expect_raises Duktape::TypeError, /is not thread/ do
        ctx.require_context(-1)
      end
    end
  end

  describe "require_function" do
    it "should not raise if the index is a function" do
      ctx.push_proc(0) do |ptr|
        env = Duktape::Context.new ptr
        env << 1 + 2
        env.return 1
      end

      ctx.require_function(-1)

      1.should eq(1)
    end

    it "should raise TypeError if the index is not a function" do
      ctx << 1

      expect_raises(Duktape::TypeError, /is not a function/) do
        ctx.require_function(-1)
      end
    end
  end

  describe "require_heapptr" do
    it "should return a Pointer(Void) on valid heapptr" do
      ctx << "get the heap ptr of this"
      ptr = ctx.require_heapptr(-1)

      ptr.class.should eq(Pointer(Void))
    end

    it "should raise TypeError when not a heap allocated object" do
      ctx << 1

      expect_raises Duktape::TypeError, /is not object\/buffer\/string/ do
        ctx.require_heapptr(-1)
      end
    end
  end

  describe "require_int" do
    it "should return an Int32 from valid number" do
      ctx << 3.14
      val = ctx.require_int -1

      val.should be_a(Int32)
      val.should eq(3)
    end

    it "should raise TypeError if not number" do
      ctx << "string"

      expect_raises Duktape::TypeError, /is not number/ do
        ctx.require_int(-1)
      end
    end
  end

  describe "require_lstring" do
    it "should return a Tuple of the string and its size" do
      str = "get this lstring"
      ctx << str
      tup = ctx.require_lstring(-1)

      tup[0].should eq(str)
      tup[1].should eq(str.size)
    end

    it "should return a empty string and size of 0" do
      str = "\0"
      ctx << str
      tup = ctx.require_lstring(-1)

      tup[0].should eq("")
      tup[1].should eq(0)
    end

    it "should raise TypeError if not string" do
      ctx << 123

      expect_raises Duktape::TypeError, /is not string/ do
        ctx.require_lstring(-1)
      end
    end
  end

  describe "require_null" do
    it "should not raise if valid null value" do
      ctx.push_null
      ctx.require_null(-1)

      # Force true if we made it this far
      1.should eq(1)
    end

    it "should raise TypeError when not null" do
      ctx << 1

      expect_raises Duktape::TypeError, /is not null/ do
        ctx.require_null(-1)
      end
    end
  end

  describe "require_number" do
    it "should return a Float64 if valid number" do
      ctx << -123.456
      val = ctx.require_number(-1)

      val.should be_a(Float64)
      val.floor.should eq(-124)
    end

    it "should raise TypeError when not a number" do
      ctx << "string"

      expect_raises Duktape::TypeError, /is not number/ do
        ctx.require_number(-1)
      end
    end

    it "should return NaN (Float64)" do
      ctx.push_nan
      val = ctx.require_number(-1)

      val.should be_a(Float64)
      val.nan?.should be_true
    end
  end

  describe "require_object" do
    context "with an invalid index" do
      it "raises Duktape::StackError" do
        expect_raises(Duktape::StackError, /invalid index/) do
          ctx.require_object(LibDUK::INVALID_INDEX)
        end
      end
    end

    context "with a valid index" do
      context "when the value at index is an object" do
        it "does not raise an error" do
          ctx.push_object
          ctx.require_object(-1)

          ctx.is_object(-1).should be_true
        end
      end

      context "when the value at index is not an object" do
        ctx << 1

        expect_raises(Duktape::TypeError, /not an object/) do
          ctx.require_object(-1)
        end
      end
    end
  end

  describe "require_object_coercible" do
    it "should not raise on valid input" do
      ctx << "object coercible"
      ctx.require_object_coercible(-1)

      # Force true if we made it this far
      1.should eq(1)
    end

    it "should raise TypeError if null" do
      ctx.push_null

      expect_raises Duktape::TypeError, /not object coercible/ do
        ctx.require_object_coercible(-1)
      end
    end

    it "should raise TypeError if null" do
      ctx.push_undefined

      expect_raises Duktape::TypeError, /not object coercible/ do
        ctx.require_object_coercible(-1)
      end
    end
  end

  describe "require_pointer" do
    it "should return a pointer(Void) on valid pointer" do
      ptr = Pointer(Void).malloc 1
      ctx.push_pointer ptr
      num = ctx.require_pointer(-1)

      num.class.should eq(Pointer(Void))
    end

    it "should raise TypeError when not a pointer" do
      ctx << 123

      expect_raises Duktape::TypeError, /not pointer/ do
        ctx.require_pointer(-1)
      end
    end
  end

  describe "require_string" do
    it "should return a string on valid input" do
      ctx << "123"
      str = ctx.require_string(-1)

      str.should eq("123")
    end

    it "should raise TypeError when not a string" do
      ctx << 1

      expect_raises Duktape::TypeError, /not string/ do
        ctx.require_string -1
      end
    end

    it "should return the empty string" do
      ctx << "\0"
      str = ctx.require_string -1

      str.should eq("")
    end
  end

  describe "require_type_mask" do
    context "with Array(Symbol)" do
      it "should not raise when types match in mask" do
        ctx << "string"
        ctx.require_type_mask(-1, [:boolean, :string, :number])

        # Force true if we made it this far
        1.should eq(1)
      end

      it "should raise TypeError when types are mismatched" do
        ctx << 123 # number

        expect_raises Duktape::TypeError, /type mismatch/ do
          ctx.require_type_mask(-1, [:boolean, :string])
        end
      end
    end

    context "with UInt32" do
      it "should not raise when types match in mask" do
        mask = LibDUK::TypeMask::Boolean | LibDUK::TypeMask::Undefined
        ctx.push_undefined
        ctx.require_type_mask(-1, mask)

        # Force true if we made it this far
        1.should eq(1)
      end

      it "should raise TypeError when types are mismatched" do
        mask = LibDUK::TypeMask::Boolean | LibDUK::TypeMask::Undefined
        ctx << 123

        expect_raises Duktape::TypeError, /type mismatch/ do
          ctx.require_type_mask(-1, mask)
        end
      end
    end
  end

  describe "require_uint" do
    it "should return a UInt32 on valid number" do
      ctx << 123
      num = ctx.require_uint(-1)

      num.should be_a(UInt32)
      num.should eq(123)
    end

    it "should return 0 for negative numbers" do
      ctx << -123
      num = ctx.require_uint(-1)

      num.should be_a(UInt32)
      num.should eq(0)
    end

    it "should raise TypeError when not a number" do
      ctx << "string"

      expect_raises Duktape::TypeError, /not number/ do
        ctx.require_uint(-1)
      end
    end
  end

  describe "require_undefined" do
    it "should not raise when an undefined is on stack" do
      ctx.push_undefined
      ctx.require_undefined(-1)

      # Force true if we made it this far
      1.should eq(1)
    end

    it "should raise TypeError when not undefined" do
      ctx << 123

      expect_raises Duktape::TypeError, /not undefined/ do
        ctx.require_undefined(-1)
      end
    end
  end
end
