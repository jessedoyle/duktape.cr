# sandbox.cr: sandboxed context for untrusted javascript
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  class Sandbox < Context
    include Support::Time
    getter timeout

    def initialize
      @ctx = Duktape.create_heap_default
      @heap_destroyed = false
      @timeout = nil
      @should_gc = true
      secure!
    end

    def initialize(context : LibDUK::Context)
      @ctx = context
      @heap_destroyed = false
      @timeout = nil
      # NOTE: Don't automatically destroy the heap
      # on finalization when given a `LibDUK::Context`.
      @should_gc = false
      secure!
    end

    def initialize(timeout : Int32 | Int64)
      timeout = timeout.to_i64
      if timeout < 100
        raise ArgumentError.new "timeout must be > 100ms"
      else
        udata = make_udata timeout
        @ctx = Duktape.create_heap_udata udata
      end
      @heap_destroyed = false
      @timeout = timeout
      @should_gc = true
      secure!
    end

    def sandbox?
      true
    end

    def timeout?
      timeout != nil
    end

    private def make_udata(timeout : Int64)
      start = current_time_nano
      tv = timeout_timeval timeout
      data = LibDUK::TimeoutData.new start: start, timeout: tv
      slc = Slice(LibDUK::TimeoutData).new 1, data
      slc.to_unsafe.as(Void*)
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
  end
end
