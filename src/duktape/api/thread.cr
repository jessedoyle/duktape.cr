# thread.cr: duktape thread operations
#
# Copyright (c) 2017 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Thread
    def suspend
      Pointer(LibDUK::ThreadState).malloc.to_slice(1).tap do |state|
        LibDUK.suspend ctx, state.to_unsafe
      end
    end

    def resume(state : Slice(LibDUK::ThreadState))
      LibDUK.resume ctx, state.to_unsafe
    end
  end
end
