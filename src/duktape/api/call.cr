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
      error:     LibDUK::Ret::Error,
      eval:      LibDUK::Ret::EvalError,
      range:     LibDUK::Ret::RangeError,
      reference: LibDUK::Ret::ReferenceError,
      syntax:    LibDUK::Ret::SyntaxError,
      type:      LibDUK::Ret::TypeError,
      uri:       LibDUK::Ret::UriError,
    }

    def call(nargs : Int32)
      require_valid_nargs nargs
      require_valid_index -(nargs + 1) # function and args
      LibDUK.pcall(ctx, nargs) == 0
    end

    def call_failure(error = :error)
      ERRORS[error].value
    rescue KeyError
      raise TypeError.new "invalid error type: #{error}"
    end

    def call_method(nargs : Int32)
      require_valid_nargs nargs
      require_valid_index -(nargs + 1) # function and args
      LibDUK.pcall_method(ctx, nargs) == 0
    end

    def call_prop(index : LibDUK::Index, nargs : Int32)
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
    def safe_call(nargs : Int32 = 0, nrets : Int32 = 0, &block : LibDUK::Context -> Int32)
      require_valid_nargs nargs
      require_valid_nargs nrets
      # TODO: We should be able to pass a *udata argument here
      # to allow for closure variables.
      LibDUK.safe_call ctx, block, Pointer(Void).null, nargs, nrets
    end

    private def require_valid_nargs(nargs : Int32) # :nodoc:
      if nargs < 0
        raise ArgumentError.new "negative argument count"
      end
    end
  end
end
