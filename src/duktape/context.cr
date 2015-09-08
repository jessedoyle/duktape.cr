# context.cr: duktape api wrapper object
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

require "./api/**"

module Duktape
  class Context
    include Duktape::API::Call
    include Duktape::API::Coercion
    include Duktape::API::Compile
    include Duktape::API::Conversion
    include Duktape::API::Debug
    include Duktape::API::ErrorHandling
    include Duktape::API::Eval
    include Duktape::API::Get
    include Duktape::API::Heap
    include Duktape::API::Object
    include Duktape::API::Pop
    include Duktape::API::Prop
    include Duktape::API::Push
    include Duktape::API::Require
    include Duktape::API::Stack
    include Duktape::API::Strings
    include Duktape::API::Type

    def initialize
      @ctx = Duktape.create_heap_default
      @heap_destroyed = false
    end

    def initialize(context : LibDUK::Context)
      @ctx = context
      @heap_destroyed = false
    end

    def finalize
      destroy_heap!
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
        raise HeapError.new \
        "heap destroyed"
      end

      @ctx
    end

    def sandbox?
      false
    end
  end
end
