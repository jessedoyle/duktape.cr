# context.cr: duktape api wrapper object
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

require "./api/**"

module Duktape
  class Context
    include API::Buffer
    include API::Call
    include API::Coercion
    include API::Compile
    include API::Conversion
    include API::Debug
    include API::ErrorHandling
    include API::Eval
    include API::Get
    include API::Heap
    include API::Object
    include API::Pop
    include API::Prop
    include API::Push
    include API::Require
    include API::Stack
    include API::Strings
    include API::Type

    def initialize
      @ctx = Duktape.create_heap_default
      @heap_destroyed = false
      @should_gc = true
    end

    def initialize(context : LibDUK::Context)
      @ctx = context
      @heap_destroyed = false
      @should_gc = false
    end

    def finalize
      destroy_heap! if should_gc?
    end

    def ctx
      raw
    end

    def destroy_heap!
      unless heap_destroyed?
        Duktape.destroy_heap @ctx
        @heap_destroyed = true
      end
    end

    def heap_destroyed?
      @heap_destroyed
    end

    def raw
      if heap_destroyed?
        raise HeapError.new "heap destroyed"
      end

      @ctx
    end

    def should_gc?
      @should_gc
    end

    def sandbox?
      false
    end

    def timeout?
      false
    end

    def timeout
      nil
    end
  end
end
