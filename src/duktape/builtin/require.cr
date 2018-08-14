module Duktape
  module BuiltIn
    struct Require < Base
      alias Engine = Context | Sandbox

      GET_CACHED_MODULE = ->(ctx : Engine, id : String) do
        ctx.push_global_stash
        ctx.get_prop_string(-1, "\xffrequireCache")
        if ctx.get_prop_string(-1, id)
          ctx.remove(-2)
          ctx.remove(-2)
          true
        else
          ctx.pop_3
          false
        end
      end

      PUT_CACHED_MODULE = ->(ctx : Engine) do
        ctx.push_global_stash
        ctx.get_prop_string(-1, "\xffrequireCache")
        ctx.dup(-3)
        ctx.get_prop_string(-1, "id")
        ctx.dup(-2)
        ctx.put_prop(-4)
        ctx.pop_3
      end

      DEL_CACHED_MODULE = ->(ctx : Engine, id : String) do
        ctx.push_global_stash
        ctx.get_prop_string(-1, "\xffrequireCache")
        ctx.del_prop_string(-1, id)
        ctx.pop_2
      end

      EVAL_MODULE_SOURCE = ->(ptr : LibDUK::Context) do
        ctx = Engine.new(ptr)
        ctx.push_string("(function(exports,require,module,__filename,__dirname){")
        src = ctx.require_string(-2)
        shebang = src.starts_with?("#!") ? "//" : ""
        ctx.push_string(shebang)
        ctx.dup(-3)
        ctx.push_string("\n})")
        ctx.concat(4)
        ctx.get_prop_string(-3, "filename")
        ctx.compile(LibDUK::Compile::Eval)
        ctx.call(0)
        ctx.push_string("name")
        ctx.push_string("main")
        ctx.def_prop(-3, LibDUK::DefProp::HaveValue | LibDUK::DefProp::Force)
        ctx.get_prop_string(-3, "exports")
        ctx.get_prop_string(-4, "require")
        ctx.dup(-5)
        ctx.get_prop_string(-6, "filename")
        ctx.push_undefined
        ctx.call(5)
        ctx.push_true
        ctx.put_prop_string(-4, "loaded")
        ctx.pop_2
        ctx.call_success
      end

      EVAL_MODULE_MAIN = ->(ctx : Engine, path : String) do
        PUSH_MODULE_OBJECT.call(ctx, path, true)
        ctx.dup(0)
        ctx.safe_call(2, 1, &EVAL_MODULE_SOURCE)
      end

      PUSH_MODULE_OBJECT = ->(ctx : Engine, id : String, main : Bool) do
        ctx.push_object

        if main
          ctx.push_global_stash
          ctx.dup(-2)
          ctx.put_prop_string(-2, "\xffmainModule")
          ctx.pop
        end

        ctx.push_string(id)
        ctx.dup(-1)
        ctx.put_prop_string(-3, "filename")
        ctx.put_prop_string(-2, "id")
        ctx.push_object
        ctx.put_prop_string(-2, "exports")
        ctx.push_false
        ctx.put_prop_string(-2, "loaded")
        PUSH_REQUIRE_FUNCTION.call(ctx, id)
        ctx.put_prop_string(-2, "require")
      end

      HANDLE_REQUIRE = ->(ptr : LibDUK::Context) do
        ctx = Engine.new(ptr)
        ctx.push_global_stash
        stash_index = ctx.normalize_index(-1)
        ctx.push_current_function
        ctx.get_prop_string(-1, "\xffmoduleId")
        parent_id = ctx.require_string(-1)
        id = ctx.require_string(0)
        ctx.get_prop_string(stash_index, "\xffmodResolve")
        ctx.dup(0)
        ctx.dup(-3)
        ctx.call(2)
        id = ctx.require_string(-1)

        if GET_CACHED_MODULE.call(ctx, id)
          ctx.get_prop_string(-1, "exports")
          return ctx.call_success
        end

        PUSH_MODULE_OBJECT.call(ctx, id, false)
        PUT_CACHED_MODULE.call(ctx)
        module_index = ctx.normalize_index(-1)
        ctx.get_prop_string(stash_index, "\xffmodLoad")
        ctx.dup(-3)
        ctx.get_prop_string(module_index, "exports")
        ctx.dup(module_index)
        success = ctx.call(3)

        if !success
          DEL_CACHED_MODULE.call(ctx, id)
          ctx.throw
        end

        if ctx.is_string(-1)
          success = ctx.safe_call(2, 1, &EVAL_MODULE_SOURCE)

          if !success
            DEL_CACHED_MODULE.call(ctx, id)
            ctx.throw
          end
        elsif ctx.is_undefined(-1)
          ctx.pop
        else
          DEL_CACHED_MODULE.call(ctx, id)
          ctx.error(LibDUK::Err::TypeError, "invalid module load callback return value")
        end

        ctx.get_prop_string(-1, "exports")
        ctx.call_success
      end

      PUSH_REQUIRE_FUNCTION = ->(ctx : Engine, id : String) do
        ctx.push_proc(1, &HANDLE_REQUIRE)
        ctx.push_string("name")
        ctx.push_string("require")
        ctx.def_prop(-3, LibDUK::DefProp::HaveValue)
        ctx.push_string(id)
        ctx.put_prop_string(-2, "\xffmoduleId")
        ctx.push_global_stash
        ctx.get_prop_string(-1, "\xffrequireCache")
        ctx.put_prop_string(-3, "cache")
        ctx.pop
        ctx.push_global_stash
        ctx.get_prop_string(-1, "\xffmainModule")
        ctx.put_prop_string(-3, "main")
        ctx.pop
      end

      INIT = ->(ctx : Engine) do
        ctx.require_object_coercible(-1)
        options_index = ctx.require_normalize_index(-1)
        ctx.push_global_stash
        ctx.push_bare_object
        ctx.put_prop_string(-2, "\xffrequireCache")
        ctx.pop
        ctx.push_global_stash
        ctx.get_prop_string(options_index, "resolve")
        ctx.require_function(-1)
        ctx.put_prop_string(-2, "\xffmodResolve")
        ctx.get_prop_string(options_index, "load")
        ctx.require_function(-1)
        ctx.put_prop_string(-2, "\xffmodLoad")
        ctx.pop
        ctx.push_global_stash
        ctx.push_undefined
        ctx.put_prop_string(-2, "\xffmainModule")
        ctx.pop
        ctx.push_global_object
        ctx.push_string("require")
        PUSH_REQUIRE_FUNCTION.call(ctx, "")
        flags = LibDUK::DefProp::HaveValue |
                LibDUK::DefProp::SetWritable |
                LibDUK::DefProp::SetConfigurable
        ctx.def_prop(-3, flags)
        ctx.pop
        ctx.pop
      end

      def import!
        INIT.call(ctx)
      end
    end
  end
end
