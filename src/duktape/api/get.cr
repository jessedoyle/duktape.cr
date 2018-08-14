# get.cr: duktape api get operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Get
    def get_boolean(index : LibDUK::Index)
      require_valid_index index
      LibDUK.get_boolean(ctx, index) == 1
    end

    def get_buffer(index : LibDUK::Index)
      require_valid_index index
      ptr = LibDUK.get_buffer(ctx, index, out size).as(UInt8*)
      ptr.to_slice size
    end

    def get_context(index : LibDUK::Index)
      require_valid_index index
      raw_ctx = LibDUK.get_context ctx, index
      # May return null pointer
      unless raw_ctx
        raise StackError.new "invalid context"
      end
      Context.new raw_ctx
    end

    def get_global_string(key : String)
      LibDUK.get_global_string(ctx, key) != 0
    end

    def get_heapptr(index : LibDUK::Index)
      require_valid_index index
      LibDUK.get_heapptr ctx, index
    end

    def get_global_heapptr(key : Void*)
      LibDUK.get_global_heapptr(ctx, key) != 0
    end

    def get_int(index : LibDUK::Index)
      require_valid_index index
      LibDUK.get_int ctx, index
    end

    def get_length(index : LibDUK::Index)
      require_valid_index index
      LibDUK.get_length ctx, index
    end

    def get_lstring(index : LibDUK::Index)
      require_valid_index index
      ptr = LibDUK.get_lstring ctx, index, out size

      if ptr
        str = String.new ptr.to_slice(size)
      else
        str = nil
      end

      {str, size}
    end

    def get_number(index : LibDUK::Index)
      require_valid_index index
      LibDUK.get_number ctx, index
    end

    def get_pointer(index : LibDUK::Index)
      require_valid_index index
      LibDUK.get_pointer ctx, index
    end

    def get_prop_string(index : LibDUK::Index, key : String)
      require_object_coercible index
      LibDUK.get_prop_string(ctx, index, key) != 0
    end

    def get_string(index : LibDUK::Index)
      require_valid_index index
      ptr = LibDUK.get_string ctx, index
      ptr ? String.new ptr : nil
    end

    def get_uint(index : LibDUK::Index)
      require_valid_index index
      LibDUK.get_uint ctx, index
    end
  end
end
