# object.cr: duktape api object operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Object
    def compact(index : LibDUK::Index)
      require_valid_index index
      LibDUK.compact ctx, index
    end

    def enum(index : LibDUK::Index, flags : UInt32)
      require_valid_index index
      unless is_object index
        raise TypeError.new "invalid object"
      end

      LibDUK.enum ctx, index, flags
    end

    def enum(index : LibDUK::Index, flags : LibDUK::Enum)
      self.enum index, flags.value
    end

    def equals(one : Int32, two : Int32)
      LibDUK.equals(ctx, one, two) == 1
    end

    def freeze(index : LibDUK::Index)
      require_valid_index index
      LibDUK.freeze ctx, index
    end

    def get_finalizer(index : LibDUK::Index)
      require_valid_index index
      LibDUK.get_finalizer ctx, index
    end

    def get_prototype(index : LibDUK::Index)
      require_valid_index index
      unless is_object index
        raise TypeError.new "invalid object"
      end

      LibDUK.get_prototype ctx, index
    end

    def instanceof(one : Int32, two : Int32)
      require_valid_index one
      require_valid_index two

      unless is_object(one) || is_object(two)
        raise TypeError.new "invalid object"
      end

      LibDUK.instanceof(ctx, one, two) == 1
    end

    def next(index : LibDUK::Index, get_val = false)
      require_valid_index index
      val = get_val ? 1 : 0
      LibDUK.next(ctx, index, val) == 1
    end

    def samevalue(one : LibDUK::Index, two : LibDUK::Index)
      LibDUK.samevalue(ctx, one, two) == 1
    end

    def seal(index : LibDUK::Index)
      require_valid_index index
      LibDUK.seal ctx, index
    end

    def set_finalizer(index : LibDUK::Index)
      require_valid_index index
      unless is_object index
        raise TypeError.new "invalid object"
      end

      LibDUK.set_finalizer ctx, index
    end

    def set_global_object
      require_valid_index -1
      unless is_object -1
        raise TypeError.new "invalid object"
      end

      LibDUK.set_global_object ctx
    end

    def set_length(index : LibDUK::Index, size : Int)
      require_valid_index index
      unless is_object -1
        raise TypeError.new "invalid object"
      end

      LibDUK.set_length ctx, index, size
    end

    def set_prototype(index : LibDUK::Index)
      require_valid_index index
      unless is_object index
        raise TypeError.new "invalid object"
      end

      LibDUK.set_prototype ctx, index
    end

    def strict_equals(one : Int32, two : Int32)
      LibDUK.strict_equals(ctx, one, two) == 1
    end
  end
end
