# error_handling.cr: duktape api error handling
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::ErrorHandling
    def error(code : Int32, msg : String)
      LibDUK.error_raw ctx, code, __FILE__, __LINE__, msg
    end

    def fatal(msg : String)
      LibDUK.fatal_raw ctx, msg
    end

    def get_error_code(index : LibDUK::Index)
      LibDUK.get_error_code ctx, index
    end

    def is_error(index : LibDUK::Index)
      get_error_code(index) != LibDUK::Err::None
    end

    def is_error?(index : LibDUK::Index)
      valid_index?(index) && is_error(index)
    end

    def raise_error(err = 0)
      # We want to return the code (0) if no
      # error is raised
      err.tap do |error|
        if error != 0
          unless valid_index? -1
            raise StackError.new "stack empty"
          end

          code = LibDUK.get_error_code ctx, -1
          msg = safe_to_string(-1)

          case code
          when LibDUK::Err::EvalError
            raise EvalError.new msg
          when LibDUK::Err::RangeError
            raise RangeError.new msg
          when LibDUK::Err::ReferenceError
            raise ReferenceError.new msg
          when LibDUK::Err::SyntaxError
            raise SyntaxError.new msg
          when LibDUK::Err::TypeError
            raise TypeError.new msg
          when LibDUK::Err::UriError
            raise URIError.new msg
          else
            raise Error.new msg
          end
        end
      end
    end

    def throw
      LibDUK.throw_raw ctx
    end
  end
end
