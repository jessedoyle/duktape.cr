require "../spec_helper"

describe Duktape::Context do
  describe "initialize" do
    it "should return a new context object" do
      ctx = Duktape::Context.new

      ctx.should be_a(Duktape::Context)
    end
  end

  describe "finalize" do
    it "should destroy the heap when finalized" do
      ctx = Duktape::Context.new
      ctx.finalize

      ctx.heap_destroyed?.should eq(true)
    end
  end

  describe "raw" do
    it "should return a LibDUK::Context" do
      ctx = Duktape::Context.new
      raw = ctx.raw

      raw.should be_a(LibDUK::Context)
    end

    it "should be aliased as #ctx" do
      ctx = Duktape::Context.new
      raw = ctx.ctx

      raw.should be_a(LibDUK::Context)
    end

    it "should raise HeapError if the heap is destroyed" do
      ctx = Duktape::Context.new
      ctx.destroy_heap!

      expect_raises Duktape::HeapError, /heap destroyed/ do
        ctx.raw
      end
    end
  end

  describe "heap_destroyed?" do
    it "returns false on initialization" do
      ctx = Duktape::Context.new

      ctx.heap_destroyed?.should be_false
    end

    it "returns true when heap is destroyed" do
      ctx = Duktape::Context.new
      ctx.destroy_heap!

      ctx.heap_destroyed?.should be_true
    end
  end

  describe "should_gc?" do
    it "should return true for a newly-created heap" do
      ctx = Duktape::Context.new

      ctx.should_gc?.should be_true
    end

    it "should return false when initialized as wrapper obj" do
      ctx = Duktape::Context.new
      wrapper = Duktape::Context.new ctx.raw

      wrapper.should_gc?.should be_false
    end
  end

  describe "sandbox?" do
    it "should return false" do
      ctx = Duktape::Context.new

      ctx.sandbox?.should be_false
    end
  end

  describe "timeout?" do
    it "should return false" do
      ctx = Duktape::Context.new

      ctx.timeout?.should be_false
    end
  end

  describe "timeout" do
    it "should return nil" do
      ctx = Duktape::Context.new

      ctx.timeout.should eq(nil)
    end
  end
end
