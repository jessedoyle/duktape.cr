# error.cr: duktape error objects
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  class InternalError < Exception
    getter msg, err

    def initialize(@msg : String)
      @err = LibDUK::ERR_INTERNAL_ERROR
      super msg
    end

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

  macro define_error_class(klass, parent)
    class {{klass}} < {{parent}}
      def initialize(msg : String)
        super msg
      end
    end
  end

  # Runtime Exception Classes
  define_error_class EvalError, Error
  define_error_class FileError, Error
  define_error_class RangeError, Error
  define_error_class ReferenceError, Error
  define_error_class StackError, Error
  define_error_class SyntaxError, Error
  define_error_class TypeError, Error
  define_error_class URIError, Error

  # Non-recoverable (Engine) Exception Classes
  define_error_class HeapError, InternalError
end
