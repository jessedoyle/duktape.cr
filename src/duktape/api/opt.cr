# opt.cr: duktape api stack default operations
#
# Copyright (c) 2017 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Opt
    def opt_boolean(index : LibDUK::Index, value : Bool)
      if valid_index?(index) && !is_boolean(index)
        raise TypeError.new "type at #{index} is not boolean"
      end
      num = value ? 1 : 0
      LibDUK.opt_boolean(ctx, index, num) == 1
    end

    def opt_number(index : LibDUK::Index, value : Float)
      if valid_index?(index) && !is_number(index)
        raise TypeError.new "type at #{index} is not number"
      end
      LibDUK.opt_number(ctx, index, value.to_f64)
    end

    def opt_int(index : LibDUK::Index, value : Int)
      if valid_index?(index) && !is_number(index)
        raise TypeError.new "type at #{index} is not number"
      end
      LibDUK.opt_int(ctx, index, value)
    end

    def opt_uint(index : LibDUK::Index, value : Int::Unsigned)
      if valid_index?(index) && !is_number(index)
        raise TypeError.new "type at #{index} is not number"
      end
      LibDUK.opt_uint(ctx, index, value)
    end

    def opt_string(index : LibDUK::Index, value : String)
      if valid_index?(index) && !is_string(index)
        raise TypeError.new "type at #{index} is not string"
      end
      String.new(LibDUK.opt_string(ctx, index, value))
    end

    def opt_lstring(index : LibDUK::Index, value : String)
      if valid_index?(index) && !is_string(index)
        raise TypeError.new "type at #{index} is not string"
      end

      ptr = LibDUK.opt_lstring(ctx, index, out size, value, value.size)
      str = String.new(ptr.to_slice(size))

      {str, size}
    end

    def opt_context(index : LibDUK::Index, value : LibDUK::Context)
      if valid_index?(index) && !is_thread(index)
        raise TypeError.new "type at #{index} is not thread"
      end
      LibDUK.opt_context(ctx, index, value)
    end
  end
end
