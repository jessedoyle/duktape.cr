# buffer.cr: duktape stack buffer operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Buffer
    def config_buffer(index : LibDUK::Index, buf : Slice(UInt8))
      unless is_external_buffer index
        raise TypeError.new "invalid external buffer"
      end

      LibDUK.config_buffer ctx, index, buf.to_unsafe.as(Void*), buf.size
    end

    def get_buffer_data(index : LibDUK::Index)
      ptr = LibDUK.get_buffer_data ctx, index, out size
      Slice(UInt8).new ptr.as(UInt8*), size
    end

    def push_buffer_object(index : LibDUK::Index, byte_offset : Int32, byte_length : Int32, flags : UInt32)
      require_buffer index
      LibDUK.push_buffer_object ctx, index, byte_offset, byte_length, flags
    end

    def push_buffer_object(index : LibDUK::Index, byte_offset : Int32, byte_length : Int32, flags : LibDUK::BufObj)
      push_buffer_object index, byte_offset, byte_length, flags.value
    end

    def require_buffer_data(index : LibDUK::Index)
      require_buffer index
      get_buffer_data index
    end

    def resize_buffer(index : LibDUK::Index, size : Int32)
      unless is_dynamic_buffer index
        raise TypeError.new "invalid dynamic buffer"
      end

      LibDUK.resize_buffer ctx, index, size
    end

    def steal_buffer(index : LibDUK::Index)
      unless is_dynamic_buffer index
        raise TypeError.new "invalid dynamic buffer"
      end

      ptr = LibDUK.steal_buffer ctx, index, out size
      Slice(UInt8).new ptr.as(UInt8*), size
    end
  end
end
