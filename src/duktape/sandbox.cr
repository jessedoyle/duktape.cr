# sandbox.cr: sandboxed context for untrusted javascript
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  class Sandbox < Context
    def initialize
      @ctx = Duktape.create_heap_default
      @heap_destroyed = false
      secure!
    end

    def initialize(context : LibDUK::Context)
      @ctx = context
      @heap_destroyed = false
      secure!
    end

    def sandbox?
      true
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
