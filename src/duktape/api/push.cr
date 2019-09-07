# push.cr: duktape api push operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Push
    def <<(value : Bool)
      push_boolean value
    end

    def <<(value : Int::Signed)
      push_int value
    end

    def <<(value : Int::Unsigned)
      push_uint value
    end

    def <<(value : String)
      push_string value
    end

    def <<(value : Nil)
      push_null
    end

    def <<(value : Float)
      push_number value.to_f64
    end

    def push_array
      LibDUK.push_array ctx
    end

    def push_bare_array
      LibDUK.push_bare_array ctx
    end

    def push_bare_object
      LibDUK.push_bare_object ctx
    end

    def push_boolean(value : Bool)
      num = value ? 1 : 0
      LibDUK.push_boolean ctx, num
    end

    def push_buffer(size : Int, resizable = false)
      if size < 0
        raise Error.new "negative buffer size"
      end

      dyn = resizable ? 1_u32 : 0_u32
      ptr = LibDUK.push_buffer_raw(ctx, size, dyn).as(UInt8*)
      ptr.to_slice size
    end

    def push_context_dump
      LibDUK.push_context_dump ctx
    end

    def push_current_function
      LibDUK.push_current_function ctx
    end

    def push_current_thread
      LibDUK.push_current_thread ctx
    end

    def push_dynamic_buffer(size : Int)
      push_buffer size, true
    end

    def push_error_object(err : Int32, msg : String)
      LibDUK.push_error_object_raw ctx, err, __FILE__, __LINE__.to_i32, msg
    end

    def push_error_object(err : LibDUK::Err, msg : String)
      push_error_object err.value, msg
    end

    def push_external_buffer
      flags = LibDUK::BufFlag::Dynamic |
              LibDUK::BufFlag::External
      LibDUK.push_buffer_raw ctx, 0, flags
    end

    def push_false
      LibDUK.push_false ctx
    end

    def push_fixed_buffer(size : Int)
      push_buffer size, false
    end

    def push_global_object
      LibDUK.push_global_object ctx
    end

    # Experimental
    def push_global_proc(name : String, nargs : Int32 = 0, &block : LibDUK::Context -> Int32)
      push_global_object
      push_proc nargs, &block
      put_prop_string -2, name
      pop
    end

    def push_global_stash
      LibDUK.push_global_stash ctx
    end

    def push_heap_stash
      LibDUK.push_heap_stash ctx
    end

    def push_heapptr(ptr : Void*)
      LibDUK.push_heapptr ctx, ptr
    end

    def push_int(value : Int)
      LibDUK.push_int ctx, value
    end

    def push_lstring(str : String, len : Int)
      if len < 0
        raise Error.new "negative string length"
      end

      ptr = LibDUK.push_lstring ctx, str, len
      String.new ptr
    end

    def push_nan
      LibDUK.push_nan ctx
    end

    def push_null
      LibDUK.push_null ctx
    end

    def push_number(value : Float)
      LibDUK.push_number ctx, value.to_f64
    end

    def push_object
      LibDUK.push_object ctx
    end

    def push_pointer(ptr : Void*)
      LibDUK.push_pointer ctx, ptr
    end

    # Experimental
    def push_proc(nargs : Int32 = 0, &block : LibDUK::Context -> Int32)
      LibDUK.push_c_function ctx, block, nargs
    end

    def push_proxy
      LibDUK.push_proxy ctx, 0_u32
    end

    def push_string(str : String)
      ptr = LibDUK.push_string ctx, str
      String.new ptr
    end

    def push_this
      LibDUK.push_this ctx
    end

    def push_new_target
      LibDUK.push_new_target ctx
    end

    def push_thread
      LibDUK.push_thread_raw ctx, 0_u32
    end

    def push_thread_new_globalenv
      LibDUK.push_thread_raw ctx, LibDUK::Thread::NewGlobalEnv
    end

    def push_thread_stash(target_ctx : LibDUK::Context)
      LibDUK.push_thread_stash ctx, target_ctx
    end

    def push_thread_stash(target_ctx : Duktape::Context)
      LibDUK.push_thread_stash ctx, target_ctx.raw
    end

    def push_true
      LibDUK.push_true ctx
    end

    def push_uint(value : UInt8 | UInt16 | UInt32 | UInt64)
      LibDUK.push_uint ctx, value.to_u32
    end

    def push_undefined
      LibDUK.push_undefined ctx
    end
  end
end
