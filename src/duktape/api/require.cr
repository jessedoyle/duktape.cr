# require.cr: duktape api stack require type operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Require
    def require_boolean(index : LibDUK::Index)
      require_valid_index index

      unless is_boolean(index)
        raise TypeError.new "type at #{index} is not boolean"
      end

      LibDUK.require_boolean(ctx, index) == 1
    end

    def require_buffer(index : LibDUK::Index)
      require_valid_index index

      unless is_buffer(index)
        raise TypeError.new "type at #{index} is not buffer"
      end

      ptr = LibDUK.require_buffer(ctx, index, out size).as(UInt8*)
      ptr.to_slice size
    end

    def require_callable(index : LibDUK::Index)
      require_function index
    end

    def require_constructable(index : LibDUK::Index)
      require_valid_index index

      unless is_constructable(index)
        raise TypeError.new "type at #{index} is not constructable"
      end

      LibDUK.require_constructable ctx, index
    end

    def require_constructor_call
      unless is_constructor_call
        raise TypeError.new "current function is not a constructor call"
      end

      LibDUK.require_constructor_call ctx
    end

    def require_context(index : LibDUK::Index)
      require_valid_index index

      unless is_thread(index)
        raise TypeError.new "type at #{index} is not thread"
      end

      raw = LibDUK.require_context ctx, index
      Context.new raw
    end

    def require_function(index : LibDUK::Index)
      require_valid_index index

      begin
        LibDUK.require_function ctx, index
      rescue ex : InternalError
        raise TypeError.new "type at #{index} is not a function"
      end
    end

    def require_heapptr(index : LibDUK::Index)
      require_valid_index index
      mask = [:object, :buffer, :string]

      unless check_type_mask(index, mask)
        raise TypeError.new "type at #{index} is not object/buffer/string"
      end

      LibDUK.require_heapptr ctx, index
    end

    def require_int(index : LibDUK::Index)
      require_valid_index index

      unless is_number(index)
        raise TypeError.new "type at #{index} is not number"
      end

      LibDUK.require_int ctx, index
    end

    def require_lstring(index : LibDUK::Index)
      require_valid_index index

      unless is_string(index)
        raise TypeError.new "type at #{index} is not string"
      end

      ptr = LibDUK.require_lstring ctx, index, out size
      str = String.new ptr.to_slice(size)

      {str, size}
    end

    def require_null(index : LibDUK::Index)
      require_valid_index index

      unless is_null(index)
        raise TypeError.new "type at #{index} is not null"
      end

      LibDUK.require_null ctx, index
    end

    def require_number(index : LibDUK::Index)
      require_valid_index index

      unless is_number(index)
        raise TypeError.new "type at #{index} is not number"
      end

      LibDUK.require_number ctx, index
    end

    def require_object(index : LibDUK::Index)
      require_valid_index index

      unless is_object(index)
        raise TypeError.new "type at #{index} is not an object"
      end

      LibDUK.require_object ctx, index
    end

    def require_object_coercible(index : LibDUK::Index)
      require_valid_index index

      mask = [
        :boolean,
        :number,
        :string,
        :object,
        :buffer,
        :pointer,
        :lightfunc,
      ]

      unless check_type_mask(index, mask)
        raise TypeError.new "type at #{index} not object coercible"
      end
    end

    def require_pointer(index : LibDUK::Index)
      require_valid_index index

      unless is_pointer(index)
        raise TypeError.new "type at #{index} not pointer"
      end

      LibDUK.require_pointer ctx, index
    end

    def require_proc(index : LibDUK::Index)
      require_valid_index index

      unless is_proc(index)
        raise TypeError.new "type at #{index} is not proc"
      end

      LibDUK.require_c_function ctx, index
    end

    def require_string(index : LibDUK::Index)
      require_valid_index index

      unless is_string(index)
        raise TypeError.new "type at #{index} not string"
      end

      ptr = LibDUK.require_string ctx, index
      String.new ptr
    end

    def require_type_mask(index : LibDUK::Index, types : Array(Symbol) | UInt32)
      require_valid_index index

      unless check_type_mask(index, types)
        raise TypeError.new "type mismatch at #{index}"
      end
    end

    def require_type_mask(index : LibDUK::Index, types : LibDUK::TypeMask)
      require_type_mask index, types.value
    end

    def require_uint(index : LibDUK::Index)
      require_valid_index index

      unless is_number(index)
        raise TypeError.new "type at #{index} is not number"
      end

      LibDUK.require_uint ctx, index
    end

    def require_undefined(index : LibDUK::Index)
      require_valid_index index

      unless is_undefined(index)
        raise TypeError.new "type at #{index} not undefined"
      end

      LibDUK.require_undefined ctx, index
    end
  end
end
