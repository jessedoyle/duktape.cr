# sandbox.cr: sandboxed context for untrusted javascript
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

# This is an exported function that is called by libduktape every so often by
# an executing VM in order to check if a timeout has occurred. The pointer
# passed is an instance of TimeoutData, which is also pointed to by a respective
# Sandbox instance.
fun duk_cr_timeout(ptr : Void*) : LibC::Int
  return 0 if ptr.null?

  timeout = ptr.unsafe_as(Duktape::TimeoutData)
  timeout.elapsed? ? 1 : 0
end

module Duktape
  class TimeoutData
    property start : Time::Span
    property timeout : Time::Span

    def initialize(@start, @timeout)
    end

    def elapsed? : Bool
      dt = Time.monotonic - @start
      dt > timeout
    end
  end

  class Sandbox < Context
    include Support::Time

    @timeout_data : TimeoutData?

    def initialize
      @ctx = Duktape.create_heap_default
      @heap_destroyed = false
      @should_gc = true
      builtin_functions
      secure!
    end

    def initialize(context : LibDUK::Context)
      @ctx = context
      @heap_destroyed = false
      # NOTE: Don't automatically destroy the heap
      # on finalization when given a `LibDUK::Context`.
      @should_gc = false
      builtin_functions
      secure!
    end

    def self.new(timeout : Int32 | Int64)
      # NOTE(z64): backwards compatibility
      Sandbox.new(timeout.milliseconds)
    end

    def initialize(timeout : Time::Span)
      if timeout < 100.milliseconds
        raise ArgumentError.new "timeout must be > 100ms"
      else
        timeout_data = TimeoutData.new(Time::Span.zero, timeout)
        @ctx = Duktape.create_heap_udata(timeout_data.unsafe_as(Pointer(Void)))
        @timeout_data = timeout_data
      end
      @heap_destroyed = false
      @should_gc = true
      builtin_functions
      secure!
    end

    def sandbox?
      true
    end

    def timeout : Int32 | Int64 | Nil
      # NOTE(z64): backwards compatibility
      @timeout_data.try do |td|
        td.timeout.total_milliseconds.to_i64
      end
    end

    def timeout?
      !@timeout_data.nil?
    end

    private def secure!
      remove_require
      remove_global_object
    end

    # Undefine internal require mechanism
    private def remove_require
      push_global_object
      del_prop_string -1, "require"
      pop
    end

    # Remove global object: Duktape
    private def remove_global_object
      push_global_object
      push_string "Duktape"
      del_prop -2
      pop
    end

    # NOTE(z64): we monkey patch the following two eval_string methods from
    # Context. this is so we can reset the start time within @timeout_data,
    # which our timeout callback will read in duk_cr_timeout.

    def eval_string(src : String)
      flags = LibDUK::Compile.new(0_u32) |
              LibDUK::Compile::Eval |
              LibDUK::Compile::NoSource |
              LibDUK::Compile::StrLen |
              LibDUK::Compile::Safe |
              LibDUK::Compile::NoFilename

      if td = @timeout_data
        td.start = Time.monotonic
      end
      LibDUK.eval_raw ctx, src, 0, flags
    end

    def eval_string_noresult(src : String)
      flags = LibDUK::Compile.new(0_u32) |
              LibDUK::Compile::Eval |
              LibDUK::Compile::Safe |
              LibDUK::Compile::NoSource |
              LibDUK::Compile::StrLen |
              LibDUK::Compile::NoResult |
              LibDUK::Compile::NoFilename

      if td = @timeout_data
        td.start = Time.monotonic
      end
      LibDUK.eval_raw ctx, src, 0, flags
    end
  end
end
