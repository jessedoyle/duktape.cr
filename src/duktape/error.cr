# error.cr: duktape error objects
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  class InternalError < Exception
    @stack : String?

    getter msg

    def initialize(@msg : String)
      super msg
    end

    def initialize(@msg : String)
      Duktape::Log::Base.fatal { "InternalError: #{msg}" }
      super msg
    end
  end

  class Error < Exception
    def initialize(msg : String)
      Duktape::Log::Base.error(exception: self) { msg }
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
