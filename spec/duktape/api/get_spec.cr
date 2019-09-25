require "../../spec_helper"

# NOTE: All the following methods raise on invalid index
# using `ctx.require_valid_index`. This mechanism is
# adequately tested in `stack_spec`, so there is no need
# to test that functionality here.

describe Duktape::API::Get do
  ctx = Duktape::Context.new

  describe "get_boolean" do
    it "should return a Bool on valid boolean value" do
      ctx << true

      ctx.get_boolean(-1).should be_true
    end

    it "should return false on non-boolean value" do
      ctx << 1

      ctx.get_boolean(-1).should be_false
    end
  end

  describe "get_buffer" do
    it "should return a Slice(UInt8) on buffer value" do
      ctx.push_buffer 10
      slc = ctx.get_buffer -1

      slc.class.should eq(Slice(UInt8))
      slc.size.should eq(10)
    end

    it "should return a null pointer on non-buffer value" do
      ctx << 1.2
      slc = ctx.get_buffer -1

      slc.to_unsafe.null?.should be_true
    end
  end

  describe "get_context" do
    it "should get a context from the stack" do
      ctx.push_thread
      new_ctx = ctx.get_context -1

      new_ctx.should be_a(Duktape::Context)
    end

    it "should raise when getting invalid context" do
      ctx << 1

      expect_raises Duktape::StackError, /invalid context/ do
        ctx.get_context -1
      end
    end
  end

  describe "get_global_string" do
    context "when property exists" do
      it "returns true" do
        ctx.get_global_string("Duktape").should be_true
      end
    end

    context "when property does not exist" do
      it "should return false" do
        ctx.get_global_string("foo").should be_false
      end
    end
  end

  describe "get_heapptr" do
    it "should get a heap pointer from the stack" do
      ctx.eval_string! "({ foo: 'bar' })"
      heap = ctx.get_heapptr -1

      heap.class.should eq(Pointer(Void))
    end
  end

  describe "get_global_heapptr" do
    context "when the property exists" do
      it "returns true" do
        ctx << "Duktape"
        ptr = ctx.get_heapptr(-1)
        val = ctx.get_global_heapptr(ptr)

        val.should be_true
        last_stack_type(ctx).should be_js_type(:object)
      end
    end

    context "when the property does not exist" do
      it "return false" do
        ctx << "foo"
        ptr = ctx.get_heapptr(-1)
        val = ctx.get_global_heapptr(ptr)

        val.should be_false
        last_stack_type(ctx).should be_js_type(:undefined)
      end
    end
  end

  describe "get_int" do
    it "should return an Int32 from the stack" do
      ctx << 3.14
      num = ctx.get_int -1

      num.should be_a(Int32)
      num.should eq(3)
    end

    it "returns 0 for invalid/NaN on stack" do
      ctx.push_nan
      num = ctx.get_int -1

      num.should be_a(Int32)
      num.should eq(0)
    end
  end

  describe "get_length" do
    it "should get the length of an object" do
      ctx.push_object
      len = ctx.get_length -1

      len.should eq(0)
    end

    it "should get the length og a string" do
      ctx << "12345"
      len = ctx.get_length -1

      len.should eq(5)
    end

    it "should get the length of a buffer" do
      ctx.push_buffer 2
      len = ctx.get_length -1

      len.should eq(2)
    end

    it "should return 0 for invalid stack element" do
      ctx.push_null
      len = ctx.get_length -1

      len.should eq(0)
    end
  end

  describe "get_lstring" do
    it "should return a with str and size" do
      str = "here's a string"
      ctx << str
      tup = ctx.get_lstring -1

      tup[0].should eq(str)
      tup[1].should eq(str.size)
    end

    it "should return size of 0 and nil on invalid element" do
      ctx << 5.678
      tup = ctx.get_lstring -1

      tup[0].should eq(nil)
      tup[1].should eq(0)
    end
  end

  describe "get_number" do
    it "should return a Float64 on valid stack value" do
      ctx << 1.2
      num = ctx.get_number -1

      num.should be_a(Float64)
      num.should eq(1.2)
    end

    it "should return NaN if value at index is not a number" do
      ctx << "string"
      num = ctx.get_number -1

      num.should be_a(Float64)
      num.nan?.should be_true
    end
  end

  describe "get_pointer" do
    it "should return a valid pointer from the stack" do
      ptr = Pointer(Void).malloc 1
      ctx.push_pointer ptr
      buf = ctx.get_pointer -1

      buf.class.should eq(Pointer(Void))
      buf.should be_truthy
    end

    it "should return a null pointer if invalid" do
      ctx << "not pointer"
      buf = ctx.get_pointer -1

      buf.class.should eq(Pointer(Void))
      buf.should eq(Pointer(Void).null)
    end
  end

  describe "get_prop_string" do
    context "when the property exists" do
      it "returns true" do
        ctx.get_global_string "Duktape"
        ctx.get_prop_string(-1, "version").should be_true
      end
    end

    context "when the property does not exist" do
      it "returns false" do
        ctx.get_prop_string(-1, "foo").should be_false
      end
    end

    context "when index is invalid" do
      it "raises an error" do
        expect_raises Duktape::StackError do
          ctx.get_prop_string(LibDUK::INVALID_INDEX, "foo").should be_false
        end
      end
    end
  end

  describe "get_string" do
    it "should return a string on valid stack value" do
      ctx << "test"
      str = ctx.get_string -1

      str.should eq("test")
    end

    it "should return nil on invalid string value" do
      ctx << 0
      str = ctx.get_string -1

      str.should eq(nil)
    end
  end

  describe "get_uint" do
    it "should return a UInt32 from valid input" do
      ctx << 16_u8
      val = ctx.get_uint -1

      val.should be_a(UInt32)
      val.should eq(16_u32)
    end

    it "returns 0 on invalid stack value" do
      ctx << "not uint"
      val = ctx.get_uint -1

      val.should be_a(UInt32)
      val.should eq(0_u32)
    end
  end
end
