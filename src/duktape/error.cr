# error.cr: duktape error objects
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  class InternalError < Exception
    getter stack, msg, err

    def initialize(ctx : LibDUK::Context, @msg : String, @err : Int32)
      # Capture the stack for later
      LibDUK.push_context_dump ctx
      ptr = LibDUK.to_string ctx, -1
      @stack = String.new ptr

      Duktape.logger.fatal "InternalError: #{msg} - #{err}"
      Duktape.logger.debug "STACK: #{stack}"

      # Cleanup
      LibDUK.destroy_heap ctx
      super msg
    end
  end

  class HeapError < InternalError
    def initialize(msg : String)
      str = "HeapError: #{msg}"
      Duktape.logger.fatal str
      super msg
    end
  end

  class StackError < Exception
    def initialize(msg : String)
      Duktape.logger.error "StackError: #{msg}"
      super msg
    end
  end

  class TypeError < Exception
    def initialize(msg : String)
      Duktape.logger.error "TypeError: #{msg}"
      super msg
    end
  end

  class Error < Exception
    def initialize(msg : String)
      Duktape.logger.error msg
      super msg
    end
  end

  class FileError < Exception
    def initialize(msg : String)
      str = "FileError: #{msg}"
      Duktape.logger.error str
      super msg
    end
  end
end
