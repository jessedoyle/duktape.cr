require "../../spec_helper"

describe Duktape::API::Push do
  ctx = Duktape::Context.new

  describe "<<" do
    context "Bool" do
      it "should push a boolean onto the stack" do
        ctx << true

        last_stack_type(ctx).should be_js_type(:boolean)
      end
    end

    context "Int" do
      it "should push a number onto the stack" do
        ctx << 123

        last_stack_type(ctx).should be_js_type(:number)
      end
    end

    context "UInt" do
      it "should push a number onto the stack" do
        ctx << 123_u32

        last_stack_type(ctx).should be_js_type(:number)
      end
    end

    context "Nil" do
      it "should push null onto the stack" do
        ctx << nil

        last_stack_type(ctx).should be_js_type(:null)
      end
    end

    context "Float" do
      it "should cast a float32 to float64" do
        ctx << 123.0_f32

        last_stack_type(ctx).should be_js_type(:number)
      end

      it "should push a number onto the stack" do
        ctx << 123.456789_f64

        last_stack_type(ctx).should be_js_type(:number)
      end
    end
  end

  describe "push_array" do
    it "should push an object onto the stack" do
      ctx.push_array

      last_stack_type(ctx).should be_js_type(:object)
    end

    it "should return the index of the array on the stack" do
      current = LibDUK.get_top(ctx.raw)
      idx = ctx.push_array

      idx.should eq(current)
    end
  end

  describe "push_boolean" do
    it "should push a boolean onto the stack" do
      ctx.push_boolean false

      last_stack_type(ctx).should be_js_type(:boolean)
    end
  end

  describe "push_bare_array" do
    it "should push an empty array onto the stack" do
      ctx.push_bare_array
      condition = ctx.is_array -1

      condition.should eq(true)
    end
  end

  describe "push_bare_object" do
    it "should push an empty object onto the stack" do
      ctx.push_bare_object

      last_stack_type(ctx).should be_js_type(:object)
    end
  end

  describe "push_buffer" do
    context "resizable/dynamic" do
      it "should push a buffer onto the stack" do
        ctx.push_buffer 8, true

        last_stack_type(ctx).should be_js_type(:buffer)
        LibDUK.is_dynamic_buffer(ctx.raw, -1).should eq(1)
      end
    end

    context "static" do
      it "should push a buffer onto the stack" do
        ctx.push_buffer 8, false

        last_stack_type(ctx).should be_js_type(:buffer)
        LibDUK.is_dynamic_buffer(ctx.raw, -1).should_not eq(1)
      end
    end

    it "should return a Slice(UInt8) pointing to the buffer" do
      slc = ctx.push_buffer 4, false

      slc.class.should eq(Slice(UInt8))
      slc.size.should eq(4)
    end

    it "should raise when negative size" do
      expect_raises Duktape::Error, /negative buffer size/ do
        ctx.push_buffer -1, false
      end
    end
  end

  describe "push_context_dump" do
    it "should push a string to the stack" do
      ctx.push_context_dump
      str = String.new(LibDUK.to_string(ctx.raw, -1))

      last_stack_type(ctx).should be_js_type(:string)
      str.should contain("ctx:")
    end
  end

  describe "push_current_function" do
    # Is it possible to push a running C function from Crystal?
    # Anyways Duktape should always push undefined
    it "should push undefined onto the stack" do
      ctx.push_current_function

      last_stack_type(ctx).should be_js_type(:undefined)
    end
  end

  describe "push_current_thread" do
    it "should push undefined onto the stack" do
      ctx.push_current_thread

      last_stack_type(ctx).should be_js_type(:undefined)
    end
  end

  describe "push_dynamic_buffer" do
    it "should push a buffer onto the stack" do
      ctx.push_dynamic_buffer 2

      last_stack_type(ctx).should be_js_type(:buffer)
    end
  end

  describe "push_error_object" do
    it "should push an error object onto the stack" do
      ctx.push_error_object LibDUK::Err::Error, "TEST"

      last_stack_type(ctx).should be_js_type(:object)
      ctx.is_error?(-1).should be_true
    end
  end

  describe "push_external_buffer" do
    it "should push an external buffer to the stack" do
      ctx.push_external_buffer

      last_stack_type(ctx).should be_js_type(:buffer)
      ctx.is_external_buffer(-1).should be_true
    end
  end

  describe "push_false" do
    it "should push false onto the stack" do
      ctx.push_false

      last_stack_type(ctx).should be_js_type(:boolean)
      ctx.to_boolean(-1).should be_false
    end
  end

  describe "push_fixed_buffer" do
    it "should push a buffer onto the stack" do
      ctx.push_fixed_buffer 2

      last_stack_type(ctx).should be_js_type(:buffer)
      LibDUK.is_dynamic_buffer(ctx.raw, -1).should_not eq(1)
    end
  end

  describe "push_global_object" do
    it "should push an object onto the stack" do
      ctx.push_global_object

      last_stack_type(ctx).should be_js_type(:object)
    end
  end

  describe "push_global_proc" do
    it "should push a native global function and name it" do
      ctx.push_global_proc("add_one", 1) do |ptr|
        env = Duktape::Context.new ptr

        begin
          num = env.require_number 0
        rescue Duktape::TypeError
          next env.call_failure :type
        end

        env << num + 1
        env.call_success
      end

      rc = ctx.eval!("add_one(42);")

      rc.should eq(0)
      ctx.is_error(-1).should be_false
      ctx.get_number(-1).should eq(43)
    end

    it "should have no visible effect on the stack" do
      top_before = ctx.get_top

      ctx.push_global_proc("add_one", 1) do |ptr|
        env = Duktape::Context.new ptr

        begin
          num = env.require_number 0
        rescue Duktape::TypeError
          next env.call_failure :type
        end

        env << num + 1
        env.call_success
      end

      top_after = ctx.get_top

      top_before.should eq(top_after)
    end
  end

  describe "push_global_stash" do
    it "should push an object onto the stack" do
      ctx.push_global_stash

      last_stack_type(ctx).should be_js_type(:object)
    end
  end

  describe "push_heap_stash" do
    it "should push an object onto the stack" do
      ctx.push_heap_stash

      last_stack_type(ctx).should be_js_type(:object)
    end
  end

  describe "push_heapptr" do
    it "should push an object onto the stack and return idx" do
      current = LibDUK.get_top(ctx.raw)
      ptr = LibDUK.get_heapptr ctx.raw, -1
      idx = ctx.push_heapptr ptr

      last_stack_type(ctx).should be_js_type(:object)
      idx.should eq(current)
    end
  end

  describe "push_int" do
    it "should push a number onto the stack" do
      ctx.push_int 3333

      last_stack_type(ctx).should be_js_type(:number)
    end
  end

  describe "push_lstring" do
    it "should push a string to the stack" do
      str = ctx.push_lstring "Really Long String", 4

      last_stack_type(ctx).should be_js_type(:string)
      str.should eq("Real")
    end

    it "should raise on negative lengths" do
      expect_raises Duktape::Error, /negative string length/ do
        ctx.push_lstring "TEST", -1
      end
    end
  end

  describe "push_nan" do
    it "should push a number to the stack" do
      ctx.push_nan

      last_stack_type(ctx).should be_js_type(:number)
      LibDUK.is_nan(ctx.raw, -1).should eq(1)
    end
  end

  describe "push_null" do
    it "should push null to the stack" do
      ctx.push_null

      last_stack_type(ctx).should be_js_type(:null)
    end
  end

  describe "push_number" do
    context "Float32" do
      it "should push a number to the stack" do
        ctx.push_number 0.00001_f32

        last_stack_type(ctx).should be_js_type(:number)
      end
    end

    context "Float64" do
      it "should push a number to the stack" do
        ctx.push_number 0.00001_f64

        last_stack_type(ctx).should be_js_type(:number)
      end
    end
  end

  describe "push_object" do
    it "should push an empty object onto the stack" do
      ctx.push_object

      last_stack_type(ctx).should be_js_type(:object)
    end
  end

  describe "push_pointer" do
    it "should push a pointer to the stack" do
      ptr = "abcd".to_unsafe.as(Pointer(Void))
      ctx.push_pointer ptr

      last_stack_type(ctx).should be_js_type(:pointer)
    end
  end

  describe "push_proc" do
    it "should push a proc onto the stack and call it" do
      # The proc will accept 2 stack arguments
      ctx.push_proc 2 do |ptr|
        env = Duktape::Context.new ptr
        a = env.get_number 0
        b = env.get_number 1
        c = a + b
        env << c
        env.call_success
      end

      # Push the arguments
      ctx << 2
      ctx << 3

      ctx.call 2

      # Get returned value
      num = ctx.get_int -1
      num.should eq(5)
    end

    it "should push undefined to the stack when called" do
      ctx.push_proc do |ptr|
        env = Duktape::Context.new ptr
        env << 42
        env.return_undefined
      end

      ctx.call 0

      last_stack_type(ctx).should be_js_type(:undefined)
    end

    it "should push a default generic error to the stack when called" do
      ctx.push_proc do |ptr|
        env = Duktape::Context.new ptr
        env.call_failure
      end

      ctx.call 0

      ctx.is_error(-1).should be_true
      ctx.safe_to_string(-1).should match(/error: error/i)
    end

    # See spec/support/proc_helper.cr
    proc_should_return_error(:error)
    proc_should_return_error(:eval)
    proc_should_return_error(:range)
    proc_should_return_error(:reference)
    proc_should_return_error(:syntax)
    proc_should_return_error(:type)
    proc_should_return_error(:uri)
  end

  describe "push_proxy" do
    it "pushes a proxy object" do
      ctx.push_object # target
      ctx.push_object # handler
      ctx.push_proxy

      last_stack_type(ctx).should be_js_type(:object)
    end
  end

  describe "push_string" do
    it "should push a string onto the stack" do
      str = ctx.push_string "Hello"

      last_stack_type(ctx).should be_js_type(:string)
      str.should eq("Hello")
    end
  end

  describe "push_this" do
    it "should push undefined to the stack" do
      ctx.push_this

      last_stack_type(ctx).should be_js_type(:undefined)
    end
  end

  describe "push_new_target" do
    it "pushes undefined if the current running function is not a constructor" do
      ctx.push_new_target

      last_stack_type(ctx).should be_js_type(:undefined)
    end
  end

  describe "push_thread" do
    it "should push object to the stack" do
      ctx.push_thread

      last_stack_type(ctx).should be_js_type(:object)
    end
  end

  describe "push_thread_new_globalenv" do
    it "should push object to the stack" do
      ctx.push_thread_new_globalenv

      last_stack_type(ctx).should be_js_type(:object)
    end
  end

  describe "push_thread_stash" do
    context "with LibDUK::Context" do
      it "should push object to the stack" do
        other = Duktape.create_heap_default
        ctx.push_thread_stash other

        last_stack_type(ctx).should be_js_type(:object)
        Duktape.destroy_heap other
      end
    end

    context "with Duktape::Context" do
      it "should push object to the stack" do
        other = Duktape::Context.new
        ctx.push_thread_stash other

        last_stack_type(ctx).should be_js_type(:object)
        other.destroy_heap!
      end
    end
  end

  describe "push_true" do
    it "should push true onto the stack" do
      ctx.push_true

      last_stack_type(ctx).should be_js_type(:boolean)
      ctx.to_boolean(-1).should be_true
    end
  end

  describe "push_uint" do
    it "should push a number onto the stack" do
      ctx << 123_u64

      last_stack_type(ctx).should be_js_type(:number)
    end
  end

  describe "push_undefined" do
    it "should push undefined to the stack" do
      ctx.push_undefined

      last_stack_type(ctx).should be_js_type(:undefined)
    end
  end
end
