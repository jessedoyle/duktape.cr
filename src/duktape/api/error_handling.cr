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

    def fatal(code : Int32, msg : String)
      LibDUK.fatal ctx, code, msg
    end

    def get_error_code(index : Int32)
      require_valid_index index
      LibDUK.get_error_code ctx, index
    end

    def is_error?(index : Int32)
      get_error_code(index) != 0
    end

    def raise_error(err = 0) # :nodoc:
      # We want to return the code (0) if no
      # error is raised
      err.tap do |error|
        unless error == 0
          unless valid_index? -1
            raise StackError.new "stack empty"
          end

          code = LibDUK.get_error_code ctx, -1
          msg  = safe_to_string(-1).gsub(/\A.*Error:\s/, "")

          case code
          when LibDUK::ERR_EVAL_ERROR
            raise EvalError.new msg
          when LibDUK::ERR_RANGE_ERROR
            raise RangeError.new msg
          when LibDUK::ERR_REFERENCE_ERROR
            raise ReferenceError.new msg
          when LibDUK::ERR_SYNTAX_ERROR
            raise SyntaxError.new msg
          when LibDUK::ERR_TYPE_ERROR
            raise TypeError.new msg
          when LibDUK::ERR_URI_ERROR
            raise URIError.new msg
          else
            raise Error.new msg
          end
        end
      end
    end

    def throw
      LibDUK.throw ctx
    end
  end
end
