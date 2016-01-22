# call.cr: duktape stack call operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  # NOTE: These methods are all equivalent to the Duktape
  # `pcall_xxx` functions because we wish to safely return
  # from errors.
  module API::Call
    ERRORS = {
      unimplemented: -LibDUK::ERR_UNIMPLEMENTED_ERROR,
      unsupported:   -LibDUK::ERR_UNSUPPORTED_ERROR,
      internal:      -LibDUK::ERR_INTERNAL_ERROR,
      alloc:         -LibDUK::ERR_ALLOC_ERROR,
      assertion:     -LibDUK::ERR_ASSERTION_ERROR,
      api:           -LibDUK::ERR_API_ERROR,
      uncaught:      -LibDUK::ERR_UNCAUGHT_ERROR,
      error:         -LibDUK::ERR_ERROR,
      eval:          -LibDUK::ERR_EVAL_ERROR,
      range:         -LibDUK::ERR_RANGE_ERROR,
      reference:     -LibDUK::ERR_REFERENCE_ERROR,
      syntax:        -LibDUK::ERR_SYNTAX_ERROR,
      type:          -LibDUK::ERR_TYPE_ERROR,
      uri:           -LibDUK::ERR_URI_ERROR,
    }

    def call(nargs : Int32)
      require_valid_nargs nargs
      require_valid_index -(nargs + 1) # function and args
      LibDUK.pcall(ctx, nargs) == 0
    end

    def call_failure(value = :error)
      ERRORS[value]
    rescue KeyError
      raise Error.new "invalid error type: #{value}"
    end

    def call_method(nargs : Int32)
      require_valid_nargs nargs
      require_valid_index -(nargs + 1) # function and args
      LibDUK.pcall_method(ctx, nargs) == 0
    end

    def call_prop(index : Int32, nargs : Int32)
      require_valid_index index
      require_valid_nargs nargs
      LibDUK.pcall_prop(ctx, index, nargs) == 0
    end

    def call_success
      1
    end

    # Equivalent to duk_pnew (protected call)
    def new(nargs : Int32)
      require_valid_nargs nargs
      LibDUK.pnew(ctx, nargs) == 0
    end

    def return(ret_val : Int32)
      ret_val
    end

    def return_undefined
      0
    end

    # Experimental
    def safe_call(nargs = 0 : Int32, nrets = 0 : Int32, &block : LibDUK::Context -> Int32)
      require_valid_nargs nargs
      require_valid_nargs nrets
      LibDUK.safe_call ctx, block, nargs, nrets
    end

    private def require_valid_nargs(nargs : Int32) # :nodoc:
      if nargs < 0
        raise Error.new "negative argument count"
      end
    end
  end
end
