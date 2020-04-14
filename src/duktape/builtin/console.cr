# console.cr: Duktape console bindings
# Copyright (c) 2017 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

# Adapted from: https://github.com/svaarala/duktape/blob/
# 0067588f691e24e0b3ab523bd7251efb31d5a164/extras/console/duk_console.c

module Duktape
  module BuiltIn
    struct Console < Base
      def import!
        ctx.push_object
        console_format
        console_log
        ctx.put_global_string "console"
      end

      private def console_format
        # console.format(arg)
        ctx.eval_string! <<-JS
          (function(E) {
            return function format(v) {
              try {
                return E('jx', v);
              } catch (e) {
                return String(v);
              }
            };
          })(typeof(Duktape) !== 'undefined' && Duktape.enc)
        JS
        ctx.put_prop_string -2, "format"
      end

      private def console_log
        # console.log(arg, ...)
        ctx.push_proc LibDUK::VARARGS do |ptr|
          env = Duktape::Context.new ptr
          top = env.get_top
          env.get_global_string "console"
          env.get_prop_string -1, "format"

          top.times do |index|
            if env.check_type_mask(index, LibDUK::TypeMask::Object)
              env.dup -1 # console.format
              env.dup index
              env.call 1
              env.replace index # arg[index] = console.format(arg[index]);
            end
          end

          env.pop_2
          env.push_string " "
          env.insert 0
          env.join top
          output = env.to_string -1
          Duktape::Log::Console.info { output }
          env.return_undefined
        end

        ctx.push_string "name"
        ctx.push_string "log"
        ctx.def_prop -3, prop_flags
        ctx.put_prop_string -2, "log"
      end

      private def prop_flags
        LibDUK::DefProp::Force.value |
          LibDUK::DefProp::HaveValue.value
      end
    end
  end
end
