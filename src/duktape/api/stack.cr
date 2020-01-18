# stack.cr: duktape api stack operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Stack
    def check_stack(extra : Int32)
      LibDUK.check_stack(ctx, extra) == 1
    end

    def check_stack_top(top : Int32)
      LibDUK.check_stack_top(ctx, top) == 1
    end

    def copy(from : Int32, to : Int32)
      require_valid_index from
      require_valid_index to
      LibDUK.copy ctx, from, to
    end

    def dup(from : Int32)
      require_valid_index from
      LibDUK.dup ctx, from
    end

    def dup_top
      require_top_index
      LibDUK.dup_top ctx
    end

    def empty?
      get_top == 0
    end

    def get_top
      LibDUK.get_top ctx
    end

    def get_top_index
      LibDUK.get_top_index ctx
    end

    def insert(to : Int32)
      require_top_index
      require_valid_index to
      LibDUK.insert ctx, to
    end

    def is_valid_index(index : LibDUK::Index)
      LibDUK.is_valid_index(ctx, index) == 1
    end

    def valid_index?(index : LibDUK::Index)
      is_valid_index index
    end

    def normalize_index(index : LibDUK::Index)
      LibDUK.normalize_index ctx, index
    end

    def pull(from : LibDUK::Index)
      require_valid_index from
      LibDUK.pull ctx, from
    end

    def remove(index : LibDUK::Index)
      require_valid_index index
      LibDUK.remove ctx, index
    end

    def replace(to : Int32)
      require_top_index
      require_valid_index to
      LibDUK.replace ctx, to
    end

    def require_normalize_index(index : LibDUK::Index)
      normalize_index(index).tap do |idx|
        if idx < 0
          raise StackError.new "invalid index: #{index}"
        end
      end
    end

    def require_stack(extra : Int32)
      check_stack(extra).tap do |fits|
        unless fits
          raise StackError.new "stack overflow"
        end
      end
    end

    def require_stack_top(top : Int32)
      check_stack_top(top).tap do |fits|
        unless fits
          raise StackError.new "stack overflow"
        end
      end
    end

    def require_top_index
      get_top_index.tap do |idx|
        if idx < 0
          raise StackError.new "stack empty"
        end
      end
    end

    def require_valid_index(index : LibDUK::Index)
      is_valid_index(index).tap do |idx|
        unless idx
          raise StackError.new "invalid index: #{index}"
        end
      end
    end

    def set_top(index : LibDUK::Index)
      require_valid_index index
      LibDUK.set_top ctx, index
    end

    def swap(idx_1 : Int32, idx_2 : Int32)
      require_valid_index idx_1
      require_valid_index idx_2
      LibDUK.swap ctx, idx_1, idx_2
    end

    def swap_top(idx : Int32)
      require_top_index
      require_valid_index idx
      LibDUK.swap_top ctx, idx
    end
  end
end
