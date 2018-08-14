# prop.cr: duktape property access operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Prop
    def def_prop(index : LibDUK::Index, flags : UInt32)
      require_valid_index index
      require_object_coercible index
      LibDUK.def_prop ctx, index, flags
    end

    def def_prop(index : LibDUK::Index, flags : LibDUK::DefProp)
      def_prop index, flags.value
    end

    def del_prop(index : LibDUK::Index)
      require_valid_index index
      require_object_coercible index
      LibDUK.del_prop(ctx, index) == 1
    end

    def del_prop_index(index : LibDUK::Index, arr_index : UInt32)
      require_valid_index index
      require_object_coercible index
      LibDUK.del_prop_index(ctx, index, arr_index) == 1
    end

    def del_prop_string(index : LibDUK::Index, key : String)
      require_valid_index index
      require_object_coercible index
      LibDUK.del_prop_string(ctx, index, key) == 1
    end

    def get_global_string(key : String)
      LibDUK.get_global_string(ctx, key) != 0
    end

    def get_prop(index : LibDUK::Index)
      require_valid_index index
      require_object_coercible index
      LibDUK.get_prop(ctx, index) == 1
    end

    def get_prop_index(index : LibDUK::Index, arr_index : UInt32)
      require_valid_index index
      require_object_coercible index
      LibDUK.get_prop_index(ctx, index, arr_index) == 1
    end

    def get_prop_string(index : LibDUK::Index, key : String)
      require_valid_index index
      require_object_coercible index
      LibDUK.get_prop_string(ctx, index, key) == 1
    end

    def has_prop(index : LibDUK::Index)
      require_valid_index index
      # Instead of accepting any object coercible value this call accepts
      # only an object as its target value. This is intentional as it
      # follows Ecmascript operator semantics.
      unless is_object index
        raise TypeError.new "invalid object"
      end
      LibDUK.has_prop(ctx, index) == 1
    end

    def has_prop_index(index : LibDUK::Index, arr_index : UInt32)
      require_valid_index index
      unless is_object index
        raise TypeError.new "invalid object"
      end
      LibDUK.has_prop_index(ctx, index, arr_index) == 1
    end

    def has_prop_string(index : LibDUK::Index, key : String)
      require_valid_index index
      unless is_object index
        raise TypeError.new "invalid object"
      end
      LibDUK.has_prop_string(ctx, index, key) == 1
    end

    def put_global_string(key : String)
      require_valid_index -1
      LibDUK.put_global_string(ctx, key) == 1
    end

    def put_global_heapptr(key : Void*)
      require_valid_index -1
      LibDUK.put_global_heapptr(ctx, key) == 1
    end

    def put_prop(index : LibDUK::Index)
      require_valid_index index
      require_object_coercible index
      LibDUK.put_prop(ctx, index) == 1
    end

    def put_prop_index(index : LibDUK::Index, arr_index : UInt32)
      require_valid_index index
      require_object_coercible index
      LibDUK.put_prop_index(ctx, index, arr_index) == 1
    end

    def put_prop_string(index : LibDUK::Index, key : String)
      require_valid_index index
      require_object_coercible index
      LibDUK.put_prop_string(ctx, index, key) == 1
    end
  end
end
