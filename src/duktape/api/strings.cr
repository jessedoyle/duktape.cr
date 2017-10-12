# strings.cr: duktape string manipulation operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Strings
    def char_code_at(index : LibDUK::Index, offset : Int32)
      require_string index
      LibDUK.char_code_at(ctx, index, offset).tap do |code|
        if code == 0
          raise Error.new "StringError: offset out of bounds"
        end
      end
    end

    def concat(count : Int32)
      require_valid_index -count
      LibDUK.concat ctx, count
    end

    # Experimental
    def decode_string(index : LibDUK::Index, &func : Void*, Int32 -> Int32)
      require_string index
      LibDUK.decode_string ctx, index, func.pointer, nil
    end

    def join(count : Int32)
      require_valid_index -(count + 1) # Separator
      LibDUK.join ctx, count
    end

    # Experimental
    def map_string(index : LibDUK::Index, &func : Void*, Int32 -> Int32)
      require_string index
      LibDUK.map_string ctx, index, func.pointer, nil
    end

    def substring(index : LibDUK::Index, start : Int32, last : Int32)
      require_string index
      LibDUK.substring ctx, index, start, last
    end

    def trim(index : LibDUK::Index)
      require_string index
      LibDUK.trim ctx, index
    end
  end
end
