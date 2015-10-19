# pop.cr: duktape stack pop operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Pop
    def pop
      if empty?
        raise StackError.new "stack empty"
      end

      LibDUK.pop ctx
    end

    def pop_2
      if get_top < 2
        raise StackError.new "stack empty"
      end

      LibDUK.pop_2 ctx
    end

    def pop_3
      if get_top < 3
        raise StackError.new "stack empty"
      end

      LibDUK.pop_3 ctx
    end

    def pop_n(count : Int32)
      if count < 0
        raise Error.new "negative count"
      end

      if get_top < count
        raise StackError.new "stack empty"
      end

      LibDUK.pop_n ctx, count
    end
  end
end
