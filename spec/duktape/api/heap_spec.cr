require "../../spec_helper"

describe Duktape::API::Heap do
  describe "gc" do
    it "should run the garbage collector" do
      ctx = Duktape::Context.new
      ctx.gc
    end
  end
end

describe Duktape do
  describe "create_heap_default" do
    it "should create a new context with internal fatal func" do
      heap = Duktape.create_heap_default

      # Test custom fatal handler by throwing an error
      expect_raises Duktape::InternalError, /uncaught error/ do
        LibDUK.fatal_raw heap, "uncaught error"
      end
    end
  end

  describe "create_heap" do
    it "should create a heap with a custom fatal func" do
      heap = Duktape.create_heap do
        num = 3 + 5
        raise Exception.new num.to_s
      end

      # Test custom fatal handler by throwing an error
      expect_raises Exception, /8/ do
        LibDUK.fatal_raw heap, "uncaught error"
      end
    end
  end

  describe "create_heap_udata" do
    it "should create a heap with a user-argument (Void*)" do
      data = "hello, world".to_unsafe.as(Void*)
      heap = Duktape.create_heap_udata(data)
      Duktape.destroy_heap heap
    end
  end

  describe "destroy_heap" do
    it "should destroy a heap" do
      heap = Duktape.create_heap_default
      Duktape.destroy_heap heap
    end
  end
end
