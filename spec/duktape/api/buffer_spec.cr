require "../../spec_helper"

describe Duktape::API::Buffer do
  describe "config_buffer" do
    it "should accept as Slice(UInt8) as an arg" do
      ctx = Duktape::Context.new
      ctx.push_external_buffer
      buf = Slice(UInt8).new 4
      ctx.config_buffer -1, buf
      slc = ctx.get_buffer_data -1

      ctx.is_external_buffer(-1).should be_true
      slc.size.should eq(4)
    end

    it "should raise when not external buffer" do
      ctx = Duktape::Context.new
      ctx.push_fixed_buffer 1
      slc = "123".to_slice

      expect_raises Duktape::TypeError, /invalid external buffer/ do
        ctx.config_buffer -1, slc
      end
    end

    it "should raise when invalid index" do
      ctx = Duktape::Context.new
      slc = "123".to_slice

      expect_raises Duktape::TypeError, /invalid external buffer/ do
        ctx.config_buffer -1, slc
      end
    end
  end

  describe "get_buffer_data" do
    it "should return a Slice(UInt8)" do
      slc = "test".to_slice
      ctx = Duktape::Context.new
      ctx.push_external_buffer
      ctx.config_buffer -1, slc
      ret = ctx.get_buffer_data -1

      ret.should be_a(Slice(UInt8))
      ret.size.should eq(4)
      String.new(ret).should eq("test")
    end

    it "should return a 0 size slice if not a buffer" do
      ctx = Duktape::Context.new
      ctx << "not buffer"
      buf = ctx.get_buffer_data -1

      buf.size.should eq(0)
    end

    it "should return a 0 size slice on invalid index" do
      ctx = Duktape::Context.new
      buf = ctx.get_buffer_data -1

      buf.size.should eq(0)
    end
  end

  describe "push_buffer_object" do
    it "should push a buffer of specified type to stack" do
      ctx = Duktape::Context.new
      ctx.push_dynamic_buffer 2
      ctx.push_buffer_object -1, 2, 0, LibDUK::BufObj::Int32Array

      last_stack_type(ctx).should be_js_type(:object) # Duktape.Buffer
    end

    it "should raise if there is no backing buffer" do
      ctx = Duktape::Context.new
      ctx << 1

      expect_raises Duktape::TypeError, /not buffer/ do
        ctx.push_buffer_object -1, 2, 0, LibDUK::BufObj::Int32Array
      end
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.push_buffer_object -1, 2, 0, LibDUK::BufObj::Int32Array
      end
    end
  end

  describe "require_buffer_data" do
    it "should return a Slice(UInt8)" do
      slc = "test".to_slice
      ctx = Duktape::Context.new
      ctx.push_external_buffer
      ctx.config_buffer -1, slc
      ret = ctx.require_buffer_data -1

      ret.should be_a(Slice(UInt8))
      ret.size.should eq(4)
      String.new(ret).should eq("test")
    end

    it "should raise if object is not a buffer" do
      ctx = Duktape::Context.new
      ctx << "not buffer"

      expect_raises Duktape::TypeError, /not buffer/ do
        ctx.require_buffer_data -1
      end
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.require_buffer_data -1
      end
    end
  end

  describe "resize_buffer" do
    it "should resize a buffer and not raise" do
      ctx = Duktape::Context.new
      ctx.push_dynamic_buffer 10
      buf = ctx.resize_buffer -1, 10

      buf.class.should eq(Pointer(Void))
    end

    it "should raise if buffer is not dynamic" do
      ctx = Duktape::Context.new
      ctx.push_fixed_buffer 10

      expect_raises Duktape::TypeError, /invalid dynamic buffer/ do
        ctx.resize_buffer -1, 10
      end
    end
  end

  describe "steal_buffer" do
    it "should return the previous buffer and reset the buffer" do
      ctx = Duktape::Context.new
      ctx.push_dynamic_buffer 2
      buf = ctx.steal_buffer -1
      cur = ctx.get_buffer_data -1

      buf.should be_a(Slice(UInt8))
      buf.size.should eq(2)
      cur.size.should eq(0)
    end

    it "should raise if object is not a dynamic buffer" do
      ctx = Duktape::Context.new
      ctx.push_fixed_buffer 1

      expect_raises Duktape::TypeError, /invalid dynamic buffer/ do
        ctx.steal_buffer -1
      end
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::TypeError, /invalid dynamic buffer/ do
        ctx.steal_buffer -1
      end
    end
  end
end
