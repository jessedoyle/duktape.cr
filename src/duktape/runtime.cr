# runtime.cr: simplified Duktape call/eval interface
#
# Copyright (c) 2016 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

require "./base"

module Duktape
  # A Runtime is a simplified mechanism for evaluating javascript code
  # without directly using the low-level Duktape API calls.
  #
  # Instances of the Runtime class may evaluate code using an interface
  # inspired by (ExecJS)[https://github.com/rails/execjs]. The method calls
  # within this class all return the last evaluated value (with the exception
  # of `exec`).
  #
  # ```
  # rt = Duktape::Runtime.new
  # rt.eval("Math.PI") # => 3.14159
  # ```
  #
  # The Runtime class also allows for javascript initialization code:
  #
  # ```
  # rt = Duktape::Runtime.new do |ctx|
  #   ctx.eval! <<-JS
  #     function add_one(num){ return num + 1; }
  #   JS
  # end
  #
  # rt.eval("add_one", 42) # => 43
  # ```
  #
  # The Runtime class is not loaded by default and must be required before
  # using it:
  #
  # ```
  # require "duktape/runtime"
  # ```
  #
  # Also note that the Runtime class includes the base Duktape code for you
  # and may be used in a standalone manner.
  #
  class Runtime
    # Code evaluating using a `Duktape::Runtime` instance will return a value
    # that depends on the last evaluated javascript expression.
    #
    # Some javascript objects are too complex to be mapped to Crystal values.
    # A `ComplexObject` instance is returned from evaluation calls when this
    # is the case.
    #
    # Currently, the primitive types such as Booleans, Numbers, Strings and
    # undefined/null are mapped directly to Crystal values.
    #
    # Any other javascript return type will be returned as an instance of
    # `ComplexObject`.
    #
    class ComplexObject
      getter kind, string

      def initialize(@kind : Symbol, @string : String)
      end

      def to_s
        "<Duktape::ComplexObject::#{kind.to_s.capitalize}>: #{string}"
      end
    end

    def initialize
      @context = Duktape::Sandbox.new
    end

    def initialize(&block)
      @context = Duktape::Sandbox.new
      yield @context
      # Remove all values from the stack left
      # over from initialization code
      @context.set_top(0) if @context.get_top > 0
    end

    # Call the named property with the supplied arguments,
    # returning the value of the called property.
    #
    # The property string can include parent objects:
    #
    # ```
    # rt = Duktape::Runtime.new
    # rt.call("JSON.stringify", 123) # => "123"
    # ```
    #
    def call(prop : String, *args)
      call prop.split("."), *args
    end

    # Call the nested property that is supplied via an
    # array of strings with the supplied arguments.
    #
    # ```
    # rt = Duktape::Runtime.new
    # rt.call(["Math", "PI"]) # => 3.14159
    # ```
    #
    def call(props : Array(String), *args)
      return nil if props.empty?

      prepare_nested_prop props
      if args.size > 0
        push_args args
        # We want a reference to the last property that was
        # successfully accessed via `get_prop`. Because we
        # leave the last property name in the chain as a string
        # , this should only depend on the number of arguments
        # on the stack.
        obj_idx = -(args.size + 2)
        @context.call_prop obj_idx, args.size
      else
        @context.get_prop -2
      end

      stack_to_crystal(-1).tap do
        @context.pop_2
      end
    end

    # Evaluate the supplied source code on the underlying javascript
    # context and return the last value:
    #
    # ```
    # rt = Duktape::Runtime.new
    # rt.eval("1 + 1") => 2.0
    # ```
    #
    def eval(source : String)
      @context.eval! source
      stack_to_crystal -1
    end

    # Execute the supplied source code on the underyling javascript
    # context without returning any value.
    #
    # ```
    # rt = Duktape::Runtime.new
    # rt.exec("1 + 1") # => nil
    # ```
    #
    def exec(source : String)
      @context.eval! source
      @context.pop
      nil
    end

    # :nodoc:
    private def stack_to_crystal(index : Int32)
      case @context.get_type(index)
      when :none
        nil
      when :undefined
        nil
      when :null
        nil
      when :boolean
        @context.get_boolean index
      when :number
        @context.get_number index
      when :string
        @context.get_string index
      when :object
        ComplexObject.new :object, object_to_string(index)
      when :buffer
        ComplexObject.new :buffer, object_to_string(index)
      when :pointer
        ComplexObject.new :pointer, object_to_string(index)
      when :lightfunc
        ComplexObject.new :lightfunc, object_to_string(index)
      else
        raise TypeError.new "invalid type at index #{index}"
      end
    end

    # :nodoc:
    private def object_to_string(index : Int32)
      @context.safe_to_string(-1).tap do
        @context.pop
      end
    end

    # :nodoc:
    private def prepare_nested_prop(props : Array(String))
      @context.push_global_object
      props.each_with_index do |prop, count|
        @context << prop
        # Break after pushing the last property name
        # so that we are able to use `call_prop` method
        # on the last property name as a string.
        break if count == props.size - 1
        @context.get_prop(-2).tap do |found|
          unless found
            raise Error.new "invalid property: #{prop}"
          end
        end
      end
    end

    # :nodoc:
    private def push_args(args)
      args.each do |arg|
        case arg
        when Int::Signed, Int::Unsigned, Bool, String, Float
          @context << arg
        when Symbol
          @context.push_string arg.to_s
        else
          raise TypeError.new "unable to convert to JS type"
        end
      end
    end
  end
end
