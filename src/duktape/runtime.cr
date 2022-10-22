# runtime.cr: simplified Duktape call/eval interface
#
# Copyright (c) 2016 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

require "./base"

module Duktape
  # Code evaluated using a `Duktape::Runtime` instance will return a value
  # that depends on the last evaluated javascript expression.
  #
  # We try our best to translate a complex object on the Duktape stack
  # to a usable Crystal value.
  #
  # Javascript objects will become Crystal hashes of type
  # Hash(String, Duktape::JSPrimitive), which is itself of type
  # Duktape::JSPrimtive.
  #
  # Javascript arrays will become Crystal arrays of type
  # Array(Duktape::JSPrimitive), which is also a
  # Duktape::JSPrimitive instance.
  #
  alias JSPrimitive = Nil | Float64 | String | Bool | Array(JSPrimitive) | Hash(String, JSPrimitive)

  # A Runtime is a simplified mechanism for evaluating javascript code
  # without directly using the low-level Duktape API calls.
  #
  # Instances of the Runtime class may evaluate code using an interface
  # inspired by [ExecJS](https://github.com/rails/execjs). The method calls
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
  # rt.eval("add_one", 42) # => 43.0
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
    @context : Duktape::Sandbox | Duktape::Context

    def initialize
      @context = Duktape::Sandbox.new
    end

    def initialize(&block)
      @context = Duktape::Sandbox.new
      yield @context
      # Remove all values from the stack left
      # over from initialization code
      reset_stack!
    end

    def initialize(timeout : Time::Span | Int32 | Int64)
      @context = Duktape::Sandbox.new timeout
    end

    def initialize(timeout : Time::Span | Int32 | Int64, &block)
      @context = Duktape::Sandbox.new timeout
      yield @context
      # Remove all values from the stack left
      # over from initialization code
      reset_stack!
    end

    def initialize(context : Duktape::Context)
      @context = context
    end

    def initialize(context : Duktape::Context, &block)
      @context = context
      yield @context
      reset_stack!
    end

    def timeout=(timeout : Time::Span?)
      ctx = @context
      if ctx.is_a?(Duktape::Sandbox)
        ctx.timeout = timeout
      end
    end

    # Call the named property with the supplied arguments,
    # returning the value of the called property.
    #
    # This call will raise a `Duktape::Error` if the
    # last evaluated expression threw an error.
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
    # This call will raise a `Duktape::Error` if the
    # last evaluated expression threw an error.
    #
    # ```
    # rt = Duktape::Runtime.new
    # rt.call(["Math", "PI"]) # => 3.14159
    # ```
    #
    def call(props : Array(String), *args)
      return nil.as(JSPrimitive) if props.empty?
      prepare_nested_prop props
      perform_call args
      check_and_raise_error
      return_last_evaluated_value
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
      return_last_evaluated_value
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
      reset_stack!
      nil
    end

    # :nodoc:
    private def check_and_raise_error
      if @context.is_error?(-1)
        code = @context.get_error_code -1
        @context.raise_error code
      end
    end

    # :nodoc:
    private def invalid_type(index : LibDUK::Index)
      raise TypeError.new "invalid type at index #{index}"
    end

    # :nodoc:
    private def next_array_element(array : Array(JSPrimitive))
      while @context.next -1, true
        array << stack_to_crystal -1
        @context.pop_2
      end
    end

    # :nodoc:
    private def next_hash_element(hash : Hash(String, JSPrimitive))
      while @context.next -1, true
        key = @context.to_string -2
        hash[key] = stack_to_crystal -1
        @context.pop_2
      end
    end

    # :nodoc:
    private def object_to_crystal(index : LibDUK::Index)
      if @context.is_function index
        # TODO: can we do better than just get a string
        # when the object is a function?
        object_to_string index
      elsif @context.is_array index
        Array(JSPrimitive).new.tap do |array|
          @context.enum index, LibDUK::Enum::ArrayIndicesOnly
          next_array_element array
          @context.pop
        end
      elsif @context.is_object index
        Hash(String, JSPrimitive).new.tap do |hash|
          @context.enum index, LibDUK::Enum::OwnPropertiesOnly
          next_hash_element hash
          @context.pop
        end
      else
        invalid_type index
      end
    end

    # :nodoc:
    private def object_to_string(index : LibDUK::Index)
      @context.safe_to_string index
    end

    # :nodoc:
    private def perform_call(args)
      push_args(args)

      obj_idx = -(args.size + 2)
      if args.size > 0
        @context.call_prop(obj_idx, args.size)
      else
        @context.get_prop(obj_idx)
        @context.call(0) if @context.is_callable(-1)
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
      args.each { |arg| push_crystal_object arg }
    end

    # :nodoc:
    private def push_crystal_object(arg : Int::Signed)
      @context.push_int arg
    end

    # :nodoc:
    private def push_crystal_object(arg : Int::Unsigned)
      @context.push_uint arg
    end

    # :nodoc:
    private def push_crystal_object(arg : Float)
      @context.push_number arg.to_f64
    end

    # :nodoc:
    private def push_crystal_object(arg : Bool)
      @context.push_boolean arg
    end

    # :nodoc:
    private def push_crystal_object(arg : Symbol)
      @context.push_string arg.to_s
    end

    # :nodoc:
    private def push_crystal_object(arg : String)
      @context.push_string arg
    end

    # :nodoc:
    private def push_crystal_object(arg : Array)
      array_index = @context.push_array
      arg.each_with_index do |object, index|
        push_crystal_object object
        @context.put_prop_index array_index, index.to_u32
      end
    end

    # :nodoc:
    private def push_crystal_object(arg : Hash(String | Symbol, _))
      @context.push_object
      arg.each do |key, value|
        @context.push_string key.to_s
        push_crystal_object value
        @context.put_prop -3
      end
    end

    # :nodoc:
    private def push_crystal_object(arg : NamedTuple)
      push_crystal_object(arg.to_h)
    end

    # :nodoc:
    private def push_crystal_object(arg)
      raise TypeError.new "unable to convert JS type"
    end

    # :nodoc:
    private def reset_stack!
      @context.set_top(0) if @context.get_top > 0
    end

    # :nodoc:
    private def return_last_evaluated_value
      (stack_to_crystal(-1).as(JSPrimitive)).tap do
        reset_stack!
      end
    end

    # :nodoc:
    private def stack_to_crystal(index : LibDUK::Index)
      case @context.get_type(index)
      when :none, :undefined, :null
        nil
      when :boolean
        @context.get_boolean index
      when :number
        @context.get_number index
      when :string
        @context.get_string index
      when :object
        object_to_crystal index
      when :buffer
        object_to_string index
      when :pointer
        object_to_string index
      when :lightfunc
        object_to_string index
      else
        invalid_type index
      end
    end
  end
end
