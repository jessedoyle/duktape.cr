# error.cr: duktape error objects
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  class InternalError < Exception
    getter msg, err

    def initialize(@ctx : LibDUK::Context, @msg : String, @err : Int32)
      Duktape.logger.fatal "InternalError: #{msg} - #{err}"
      Duktape.logger.debug "STACK: #{stack}"
      super msg
    end

    def stack
      @stack ||= make_stack
    end

    private def make_stack
      LibDUK.push_context_dump @ctx
      ptr = LibDUK.safe_to_lstring @ctx, -1, out size
      String.new(ptr.to_slice(size)).tap do
        LibDUK.pop @ctx
      end
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

  class HeapError < Exception
    def initialize(msg : String)
      str = "HeapError: #{msg}"
      Duktape.logger.fatal str
      super msg
    end
  end

  class StackError < Exception
    def initialize(msg : String)
      str = "StackError: #{msg}"
      Duktape.logger.error str
      super msg
    end
  end

  class TypeError < Exception
    def initialize(msg : String)
      str = "TypeError: #{msg}"
      Duktape.logger.error str
      super msg
    end
  end

end
