# coercion.cr: duktape api stack coercion operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Coercion
    def safe_to_lstring(index : Int)
      require_valid_index index
      ptr = LibDUK.safe_to_lstring ctx, index, out size
      str = String.new ptr.to_slice(size)
      { str, size }
    end

    def safe_to_string(index : Int)
      safe_to_lstring(index).first
    end

    def to_boolean(index : Int)
      require_valid_index index
      LibDUK.to_boolean(ctx, index) == 1
    end

    # Returns a slice to the buffer that was coerced at `index`.
    def to_buffer(index)
      require_valid_index index
      flags = LibDUK::BUF_MODE_DONTCARE
      ptr   = LibDUK.to_buffer_raw(ctx, index, out size, flags) as UInt8*
      ptr.to_slice size
    end

    def to_defaultvalue(index : Int, hint = LibDUK::HINT_STRING)
      require_valid_index index
      unless is_object index
        raise TypeError.new \
        "invalid object"
      end
      LibDUK.to_defaultvalue ctx, index, hint
    end

    def to_dynamic_buffer(index : Int)
      require_valid_index index
      flags = LibDUK::BUF_MODE_DYNAMIC
      ptr   = LibDUK.to_buffer_raw(ctx, index, out size, flags) as UInt8*
      Slice.new ptr, size
    end

    def to_fixed_buffer(index : Int)
      require_valid_index index
      flags = LibDUK::BUF_MODE_FIXED
      ptr   = LibDUK.to_buffer_raw(ctx, index, out size, flags) as UInt8*
      Slice.new ptr, size
    end

    def to_int(index : Int)
      require_valid_index index
      LibDUK.to_int ctx, index
    end

    def to_int32(index : Int)
      require_valid_index index
      LibDUK.to_int32 ctx, index
    end

    def to_lstring(index : Int)
      require_valid_index index
      ptr = LibDUK.to_lstring ctx, index, out size
      str = String.new ptr.to_slice(size)
      { str, size }
    end

    def to_null(index : Int)
      require_valid_index index
      LibDUK.to_null ctx, index
    end

    def to_number(index : Int)
      require_valid_index index
      LibDUK.to_number(ctx, index).to_f64
    end

    def to_object(index : Int)
      require_object_coercible index
      LibDUK.to_object ctx, index
    end

    def to_pointer(index : Int)
      require_valid_index index
      LibDUK.to_pointer ctx, index
    end

    def to_primitive(index : Int, hint = LibDUK::HINT_STRING)
      require_valid_index index
      LibDUK.to_primitive ctx, index, hint
    end

    def to_string(index : Int)
      require_valid_index index
      to_lstring(index).first
    end

    def to_uint(index : Int)
      require_valid_index index
      LibDUK.to_uint(ctx, index).to_u32
    end

    def to_uint16(index : Int)
      require_valid_index index
      LibDUK.to_uint16(ctx, index).to_u16
    end

    def to_uint32(index : Int)
      require_valid_index index
      LibDUK.to_uint32(ctx, index).to_u32
    end

    def to_undefined(index : Int)
      require_valid_index index
      LibDUK.to_undefined ctx, index
    end
  end
end
