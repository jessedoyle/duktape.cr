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

    def throw
      LibDUK.throw ctx
    end
  end
end
