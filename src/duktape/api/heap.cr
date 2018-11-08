# heap.cr: duktape heap/memory operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Heap
    def gc
      LibDUK.gc ctx, 0_u32
    end
  end

  def self.create_heap(udata : Void*? = nil, &fatal : Void*, UInt8* -> NoReturn)
    LibDUK.create_heap(nil, nil, nil, udata, fatal.pointer).tap do |ctx|
      unless ctx
        raise HeapError.new "unable to initialize"
      end
    end
  end

  def self.create_heap_default
    create_heap do |_, msg|
      str = String.new msg
      raise Duktape::InternalError.new str
    end
  end

  def self.create_heap_udata(udata : Void*)
    create_heap(udata) do |_, msg|
      str = String.new msg
      raise Duktape::InternalError.new str
    end
  end

  def self.destroy_heap(ctx : LibDUK::Context)
    LibDUK.destroy_heap ctx
  end
end
