# print.cr: Duktape print() function.
# Copyright (c) 2017 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module BuiltIn
    struct Print < Base
      def import!
        ctx.push_global_proc("print", LibDUK::VARARGS) do |ptr|
          env = Duktape::Context.new ptr
          nargs = env.get_top
          output = String.build do |str|
            nargs.times do |index|
              str << " " unless index == 0
              str << env.safe_to_string index
            end
          end
          Duktape::Log::Base.info { output }
          env.return_undefined
        end
      end
    end
  end
end
