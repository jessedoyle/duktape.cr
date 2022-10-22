# lib_duktape.cr: crystal bindings for duktape
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

@[Link(ldflags: "-L#{__DIR__}/.build/lib -L#{__DIR__}/.build/include -lduktape -lm")]
lib LibDUK
  alias Context = Void*
  alias Size = LibC::SizeT
  alias Bool = UInt32
  alias Index = Int32
  alias Number = Float64

  INVALID_INDEX = Int32::MIN
  VARARGS       = -1

  enum Type : UInt32
    Min       = 0
    None      = 0
    Undefined # 1
    Null      # 2
    Boolean   # 3
    Number    # 4
    String    # 5
    Object    # 6
    Buffer    # 7
    Pointer   # 8
    Lightfunc # 9
    Max       = 9
  end

  enum TypeMask : UInt32
    None      = 1 << Type::None
    Undefined = 1 << Type::Undefined
    Null      = 1 << Type::Null
    Boolean   = 1 << Type::Boolean
    Number    = 1 << Type::Number
    String    = 1 << Type::String
    Object    = 1 << Type::Object
    Buffer    = 1 << Type::Buffer
    Pointer   = 1 << Type::Pointer
    Lightfunc = 1 << Type::Lightfunc
    Throw     = 1 << 10 # Internal
    Promote   = 1 << 11 # Internal
  end

  enum Hint : UInt32
    None   # 0
    String # 1
    Number # 2
  end

  @[Flags]
  enum Enum : UInt32
    IncludeNonEnumerable # (1 << 0)
    IncludeHidden        # (1 << 1)
    IncludeSymbols       # (1 << 2)
    ExcludeStrings       # (1 << 3)
    OwnPropertiesOnly    # (1 << 4)
    ArrayIndicesOnly     # (1 << 5)
    SortArrayIndices     # (1 << 6)
    NoProxyBehavior      # (1 << 7)
  end

  enum Compile : UInt32
    Eval       = (1 << 3)
    Function   = (1 << 4)
    Strict     = (1 << 5)
    Shebang    = (1 << 6)
    Safe       = (1 << 7)
    NoResult   = (1 << 8)
    NoSource   = (1 << 9)
    StrLen     = (1 << 10)
    NoFilename = (1 << 11)
    FuncExpr   = (1 << 12)
  end

  @[Flags]
  enum DefProp : UInt32
    Writable         # (1 << 0)
    Enumerable       # (1 << 1)
    Configurable     # (1 << 2)
    HaveWritable     # (1 << 3)
    HaveEnumerable   # (1 << 4)
    HaveConfigurable # (1 << 5)
    HaveValue        # (1 << 6)
    HaveGetter       # (1 << 7)
    HaveSetter       # (1 << 8)
    Force            # (1 << 9)
    SetWritable       = HaveWritable | Writable
    ClearWritable     = HaveWritable
    SetEnumerable     = HaveEnumerable | Enumerable
    ClearEnumerable   = HaveEnumerable
    SetConfigurable   = HaveConfigurable | Configurable
    ClearConfigurable = HaveConfigurable
  end

  enum Thread
    NewGlobalEnv
  end

  enum GC
    Compact
  end

  enum Err
    None           # 0
    Error          # 1
    EvalError      # 2
    RangeError     # 3
    ReferenceError # 4
    SyntaxError    # 5
    TypeError      # 6
    UriError       # 7
  end

  enum Ret
    Error          = -Err::Error
    EvalError      = -Err::EvalError
    RangeError     = -Err::RangeError
    ReferenceError = -Err::ReferenceError
    SyntaxError    = -Err::SyntaxError
    TypeError      = -Err::TypeError
    UriError       = -Err::UriError
  end

  enum Exec : UInt32
    Success # 0
    Error   # 1
  end

  enum Level : UInt32
    Debug   # 0
    DDebug  # 1
    DDDebug # 2
  end

  @[Flags]
  enum BufFlag : UInt32
    Dynamic  # (1 << 0)
    External # (1 << 1)
    NoZero   # (1 << 2)
  end

  enum BufObj : UInt32
    ArrayBuffer       # 0
    NodeJsBuffer      # 1
    DataView          # 2
    Int8Array         # 3
    UInt8Array        # 4
    UInt8ClampedArray # 5
    Int16Array        # 6
    UInt16Array       # 7
    Int32Array        # 8
    UInt32Array       # 9
    Float32Array      # 10
    Float64Array      # 11
  end

  enum BufMode
    Fixed
    Dynamic
    DontCare
  end

  struct ThreadState
    data : UInt8[128]
  end

  struct MemoryFunctions
    alloc_func : Void*
    realloc_func : Void*
    free_func : Void*
    udata : Void*
  end

  struct FuncListEntry
    key : UInt8*
    value : Int32
    nargs : Int32
  end

  struct NumberListEntry
    key : UInt8*
    value : Number
  end

  struct TimeComponents
    year : Number
    month : Number
    day : Number
    hours : Number
    minutes : Number
    seconds : Number
    milliseconds : Number
    weekday : Number
  end

  # Context Management
  fun create_heap = duk_create_heap(alloc_func : Void*, realloc_func : Void*, free_func : Void*, heap_data : Void*, fatal_func : Void*) : Context
  fun destroy_heap = duk_destroy_heap(ctx : Context)
  fun suspend = duk_suspend(ctx : Context, thread_state : ThreadState*)
  fun resume = duk_resume(ctx : Context, thread_state : ThreadState*)

  # Memory Functions
  fun alloc_raw = duk_alloc_raw(ctx : Context, size : Size) : Void*
  fun free_raw = duk_free_raw(ctx : Context, ptr : Void*)
  fun realloc_raw = duk_realloc_raw(ctx : Context, ptr : Void*, size : Size) : Void*
  fun alloc = duk_alloc(ctx : Context, size : Size) : Void*
  fun free = duk_free(ctx : Context, ptr : Void*)
  fun realloc = duk_realloc(ctx : Context, ptr : Void*, size : Size) : Void*
  fun get_memory_functions = duk_get_memory_functions(ctx : Context, out_funcs : MemoryFunctions*)
  fun gc = duk_gc(ctx : Context, flags : UInt32)

  # Error Handling
  @[Raises]
  fun throw_raw = duk_throw_raw(ctx : Context)
  @[Raises]
  fun error_raw = duk_error_raw(ctx : Context, err_code : Int32, filename : UInt8*, line : Int32, fmt : UInt8*, ...)
  @[Raises]
  fun fatal_raw = duk_fatal_raw(ctx : Context, msg : UInt8*)

  # State-related
  fun is_strict_call = duk_is_strict_call(ctx : Context) : Bool
  fun is_constructor_call = duk_is_constructor_call(ctx : Context) : Bool

  # Stack Management
  fun normalize_index = duk_normalize_index(ctx : Context, index : Index) : Index
  fun require_normalize_index = duk_require_normalize_index(ctx : Context, index : Index) : Index
  fun is_valid_index = duk_is_valid_index(ctx : Context, index : Index) : Bool
  fun require_valid_index = duk_require_valid_index(ctx : Context, index : Index)
  fun get_top = duk_get_top(ctx : Context) : Index
  fun set_top = duk_set_top(ctx : Context, index : Index)
  fun get_top_index = duk_get_top_index(ctx : Context) : Index
  fun require_top_index = duk_require_top_index(ctx : Context) : Index
  fun check_stack = duk_check_stack(ctx : Context, extra : Index) : Bool
  fun require_stack = duk_require_stack(ctx : Context, extra : Index)
  fun check_stack_top = duk_check_stack_top(ctx : Context, top : Index) : Bool
  fun require_stack_top = duk_require_stack_top(ctx : Context, top : Index)

  # Stack Manipulation
  fun swap = duk_swap(ctx : Context, idx_1 : Index, idx_2 : Index)
  fun swap_top = duk_swap_top(ctx : Context, index : Index)
  fun dup = duk_dup(ctx : Context, from_index : Index)
  fun dup_top = duk_dup_top(ctx : Context)
  fun insert = duk_insert(ctx : Context, to_index : Index)
  fun pull = duk_pull(ctx : Context, from_index : Index)
  fun replace = duk_replace(ctx : Context, to_index : Index)
  fun copy = duk_copy(ctx : Context, from_index : Index, to_index : Index)
  fun remove = duk_remove(ctx : Context, index : Index)
  fun xcopymove_raw = duk_xcopymove_raw(to : Context, from : Context, count : Index, is_copy : Bool)

  # Push Operations
  fun push_undefined = duk_push_undefined(ctx : Context)
  fun push_null = duk_push_null(ctx : Context)
  fun push_boolean = duk_push_boolean(ctx : Context, val : Bool)
  fun push_true = duk_push_true(ctx : Context)
  fun push_false = duk_push_false(ctx : Context)
  fun push_number = duk_push_number(ctx : Context, val : Number)
  fun push_nan = duk_push_nan(ctx : Context)
  fun push_int = duk_push_int(ctx : Context, val : Int32)
  fun push_uint = duk_push_uint(ctx : Context, val : UInt32)
  fun push_string = duk_push_string(ctx : Context, str : UInt8*) : UInt8*
  fun push_lstring = duk_push_lstring(ctx : Context, str : UInt8*, len : Size) : UInt8*
  fun push_pointer = duk_push_pointer(ctx : Context, ptr : Void*)
  fun push_this = duk_push_this(ctx : Context)
  fun push_new_target = duk_push_new_target(ctx : Context)
  fun push_current_function = duk_push_current_function(ctx : Context)
  fun push_current_thread = duk_push_current_thread(ctx : Context)
  fun push_global_object = duk_push_global_object(ctx : Context)
  fun push_heap_stash = duk_push_heap_stash(ctx : Context)
  fun push_global_stash = duk_push_global_stash(ctx : Context)
  fun push_thread_stash = duk_push_thread_stash(ctx : Context, target : Context)
  fun push_object = duk_push_object(ctx : Context) : Index
  fun push_bare_object = duk_push_bare_object(ctx : Context) : Index
  fun push_array = duk_push_array(ctx : Context) : Index
  fun push_c_function = duk_push_c_function(ctx : Context, func : Context -> Int32, nargs : Index) : Index
  fun push_c_lightfunc = duk_push_c_lightfunc(ctx : Context, func : Context -> Int32, nargs : Index) : Index
  fun push_proxy = duk_push_proxy(ctx : Context, flags : UInt32) : Index
  fun push_thread_raw = duk_push_thread_raw(ctx : Context, flags : UInt32) : Index
  fun push_error_object_raw = duk_push_error_object_raw(ctx : Context, err : Int32, filename : UInt8*, line : Int32, fmt : UInt8*, ...) : Index
  fun push_error_object_stash = duk_push_error_object_stash(ctx : Context, err : Int32, fmt : UInt8*, ...) : Int32
  fun push_error_object_va_raw = duk_push_error_object_va_raw(ctx : Context, err : Int32, filename : UInt8*, line : Int32, fmt : UInt8*, ap : Void*) : Int32
  fun push_buffer_raw = duk_push_buffer_raw(ctx : Context, size : Size, flags : UInt32) : Void*
  fun push_buffer_object = duk_push_buffer_object(ctx : Context, buffer : Index, offset : Size, length : Size, flags : UInt32)
  fun push_heapptr = duk_push_heapptr(ctx : Context, ptr : Void*) : Index
  fun push_bare_array = duk_push_bare_array(ctx : Context) : Index

  # Pop Operations
  fun pop = duk_pop(ctx : Context)
  fun pop_n = duk_pop_n(ctx : Context, count : Index)
  fun pop_2 = duk_pop_2(ctx : Context)
  fun pop_3 = duk_pop_3(ctx : Context)

  # Type Checks
  fun get_type = duk_get_type(ctx : Context, index : Index) : Int32
  fun check_type = duk_check_type(ctx : Context, index : Index, t : Int32) : Bool
  fun get_type_mask = duk_get_type_mask(ctx : Context, index : Index) : UInt32
  fun check_type_mask = duk_check_type_mask(ctx : Context, index : Index, mask : UInt32) : Bool
  fun is_undefined = duk_is_undefined(ctx : Context, index : Index) : Bool
  fun is_null = duk_is_null(ctx : Context, index : Index) : Bool
  fun is_boolean = duk_is_boolean(ctx : Context, index : Index) : Bool
  fun is_number = duk_is_number(ctx : Context, index : Index) : Bool
  fun is_nan = duk_is_nan(ctx : Context, index : Index) : Bool
  fun is_string = duk_is_string(ctx : Context, index : Index) : Bool
  fun is_object = duk_is_object(ctx : Context, index : Index) : Bool
  fun is_buffer = duk_is_buffer(ctx : Context, index : Index) : Bool
  fun is_buffer_data = duk_is_buffer_data(ctx : Context, index : Index) : Bool
  fun is_pointer = duk_is_pointer(ctx : Context, index : Index) : Bool
  fun is_lightfunc = duk_is_lightfunc(ctx : Context, index : Index) : Bool
  fun is_symbol = duk_is_symbol(ctx : Context, index : Index) : Bool
  fun is_array = duk_is_array(ctx : Context, index : Index) : Bool
  fun is_function = duk_is_function(ctx : Context, index : Index) : Bool
  fun is_c_function = duk_is_c_function(ctx : Context, index : Index) : Bool
  fun is_ecmascript_function = duk_is_ecmascript_function(ctx : Context, index : Index) : Bool
  fun is_bound_function = duk_is_bound_function(ctx : Context, index : Index) : Bool
  fun is_thread = duk_is_thread(ctx : Context, index : Index) : Bool
  fun is_constructable = duk_is_constructable(context : Context, index : Index) : Bool
  fun is_dynamic_buffer = duk_is_dynamic_buffer(ctx : Context, index : Index) : Bool
  fun is_fixed_buffer = duk_is_fixed_buffer(ctx : Context, index : Index) : Bool
  fun is_external_buffer = duk_is_external_buffer(ctx : Context, index : Index) : Bool

  # Get Operations
  fun get_error_code = duk_get_error_code(ctx : Context, index : Index) : Err
  fun get_boolean = duk_get_boolean(ctx : Context, index : Index) : Bool
  fun get_number = duk_get_number(ctx : Context, index : Index) : Number
  fun get_int = duk_get_int(ctx : Context, index : Index) : Int32
  fun get_uint = duk_get_uint(ctx : Context, index : Index) : UInt32
  fun get_string = duk_get_string(ctx : Context, index : Index) : UInt8*
  fun get_lstring = duk_get_lstring(ctx : Context, index : Index, out_len : Size*) : UInt8*
  fun get_buffer = duk_get_buffer(ctx : Context, index : Index, out_size : Size*) : Void*
  fun get_buffer_data = duk_get_buffer_data(ctx : Context, index : Index, out_size : Size*) : Void*
  fun get_pointer = duk_get_pointer(ctx : Context, index : Index) : Void*
  fun get_c_function = duk_get_c_function(ctx : Context, index : Index) : Void*
  fun get_context = duk_get_context(ctx : Context, index : Index) : Context
  fun get_heapptr = duk_get_heapptr(ctx : Context, index : Index) : Void*
  fun get_global_heapptr = duk_get_global_heapptr(ctx : Context, key : Void*) : Bool
  fun get_length = duk_get_length(ctx : Context, index : Index) : Size
  fun set_length = duk_set_length(ctx : Context, index : Index, size : Size)
  fun get_global_string = duk_get_global_string(ctx : Context, key : UInt8*) : Bool
  fun get_prop_string = duk_get_prop_string(ctx : Context, index : Index, key : UInt8*) : Bool

  # Require Operations
  fun require_undefined = duk_require_undefined(ctx : Context, index : Index)
  fun require_null = duk_require_null(ctx : Context, index : Index)
  fun require_boolean = duk_require_boolean(ctx : Context, index : Index) : Bool
  fun require_number = duk_require_number(ctx : Context, index : Index) : Number
  fun require_int = duk_require_int(ctx : Context, index : Index) : Int32
  fun require_uint = duk_require_uint(ctx : Context, index : Index) : UInt32
  fun require_string = duk_require_string(ctx : Context, index : Index) : UInt8*
  fun require_lstring = duk_require_lstring(ctx : Context, index : Index, out_len : Size*) : UInt8*
  fun require_object = duk_require_object(ctx : Context, index : Index)
  fun require_buffer = duk_require_buffer(ctx : Context, index : Index, out_size : Size*) : Void*
  fun require_buffer_data = duk_require_buffer_data(ctx : Context, index : Index, out_size : Size*) : Void*
  fun require_pointer = duk_require_pointer(ctx : Context, index : Index) : Void*
  fun require_c_function = duk_require_c_function(ctx : Context, index : Index) : Void*
  fun require_context = duk_require_context(ctx : Context, index : Index) : Context
  fun require_heapptr = duk_require_heapptr(ctx : Context, index : Index) : Void*
  @[Raises]
  fun require_function = duk_require_function(ctx : Context, index : Index)
  fun require_constructable = duk_require_constructable(ctx : Context, index : Index)
  fun require_constructor_call = duk_require_constructor_call(ctx : Context)

  # Stack Defaults (like duk_require_xxx, allows a default value to be passed)
  fun opt_boolean = duk_opt_boolean(ctx : Context, index : Index, value : Bool) : Bool
  fun opt_number = duk_opt_number(ctx : Context, index : Index, value : Number) : Number
  fun opt_int = duk_opt_int(ctx : Context, index : Index, value : Int32) : Int32
  fun opt_uint = duk_opt_uint(ctx : Context, index : Index, value : UInt32) : UInt32
  fun opt_string = duk_opt_string(ctx : Context, index : Index, value : UInt8*) : UInt8*
  fun opt_lstring = duk_opt_lstring(ctx : Context, index : Index, out_size : Size*, value : UInt8*, size : Size) : UInt8*
  fun opt_buffer = duk_opt_buffer(ctx : Context, index : Index, out_size : Size*, value : Void*, size : Size) : Void*
  fun opt_buffer_data = duk_opt_buffer_data(ctx : Context, index : Index, out_size : Size*, value : Void*, size : Size) : Void*
  fun opt_pointer = duk_opt_pointer(ctx : Context, index : Index, value : Void*) : Void*
  fun opt_c_function = duk_opt_c_function(ctx : Context, index : Index, value : Void*) : Void*
  fun opt_context = duk_opt_context(ctx : Context, index : Index, value : Context) : Context
  fun opt_heapptr = duk_opt_heapptr(ctx : Context, index : Index, value : Void*) : Void*

  # Coercion Operations
  fun to_undefined = duk_to_undefined(ctx : Context, index : Index)
  fun to_null = duk_to_null(ctx : Context, index : Index)
  fun to_boolean = duk_to_boolean(ctx : Context, index : Index) : Bool
  fun to_number = duk_to_number(ctx : Context, index : Index) : Number
  fun to_int = duk_to_int(ctx : Context, index : Index) : Int32
  fun to_uint = duk_to_uint(ctx : Context, index : Index) : UInt32
  fun to_int32 = duk_to_int32(ctx : Context, index : Index) : Int32
  fun to_uint32 = duk_to_uint32(ctx : Context, index : Index) : UInt32
  fun to_uint16 = duk_to_uint16(ctx : Context, index : Index) : UInt16
  fun to_string = duk_to_string(ctx : Context, index : Index) : UInt8*
  fun to_lstring = duk_to_lstring(ctx : Context, index : Index, out_len : Size*) : UInt8*
  fun to_buffer_raw = duk_to_buffer_raw(ctx : Context, index : Index, out_size : Size*, flags : UInt32) : Void*
  fun to_pointer = duk_to_pointer(ctx : Context, index : Index) : Void*
  fun to_object = duk_to_object(ctx : Context, index : Index)
  fun to_primitive = duk_to_primitive(cts : Context, index : Index, hint : Int32)
  fun safe_to_lstring = duk_safe_to_lstring(ctx : Context, index : Index, out_len : Size*) : UInt8*
  fun safe_to_stacktrace = duk_safe_to_stacktrace(ctx : Context, index : Index) : UInt8*
  fun to_stacktrace = duk_to_stacktrace(ctx : Context, index : Index) : UInt8*

  # Misc Conversion
  fun base64_encode = duk_base64_encode(ctx : Context, index : Index) : UInt8*
  fun base64_decode = duk_base64_decode(ctx : Context, index : Index)
  fun hex_encode = duk_hex_encode(ctx : Context, index : Index) : UInt8*
  fun hex_decode = duk_hex_decode(ctx : Context, index : Index)
  fun json_encode = duk_json_encode(ctx : Context, index : Index) : UInt8*
  fun json_decode = duk_json_decode(ctx : Context, index : Index)
  fun buffer_to_string = duk_buffer_to_string(ctx : Context, index : Index) : UInt8*

  # Buffer Operations
  fun resize_buffer = duk_resize_buffer(ctx : Context, index : Index, new_size : Size) : Void*
  fun steal_buffer = duk_steal_buffer(ctx : Context, index : Index, out_size : Size*) : Void*
  fun config_buffer = duk_config_buffer(ctx : Context, index : Index, ptr : Void*, len : Size)

  # Property Access
  fun get_prop = duk_get_prop(ctx : Context, obj_index : Index) : Bool
  fun get_prop_string = duk_get_prop_string(ctx : Context, obj_index : Index, key : UInt8*) : Bool
  fun get_prop_lstring = duk_get_prop_lstring(ctx : Context, obj_index : Index, key : UInt8*, length : Size) : Bool
  fun get_prop_index = duk_get_prop_index(ctx : Context, obj_index : Index, arr_index : UInt32) : Bool
  fun put_prop = duk_put_prop(ctx : Context, obj_index : Index) : Bool
  fun put_prop_string = duk_put_prop_string(ctx : Context, obj_index : Index, key : UInt8*) : Bool
  fun put_prop_lstring = duk_put_prop_lstring(ctx : Context, obj_index : Index, key : UInt8*, length : Size) : Bool
  fun put_prop_index = duk_put_prop_index(ctx : Context, obj_index : Index, arr_index : UInt32) : Bool
  fun del_prop = duk_del_prop(ctx : Context, obj_index : Index) : Bool
  fun del_prop_string = duk_del_prop_string(ctx : Context, obj_index : Index, key : UInt8*) : Bool
  fun del_prop_lstring = duk_del_prop_lstring(ctx : Context, obj_index : Index, key : UInt8*, length : Size) : Bool
  fun del_prop_index = duk_del_prop_index(ctx : Context, obj_index : Index, arr_index : UInt32) : Bool
  fun has_prop = duk_has_prop(ctx : Context, obj_index : Index) : Int32
  fun has_prop_string = duk_has_prop_string(ctx : Context, obj_index : Index, key : UInt8*) : Bool
  fun has_prop_lstring = duk_has_prop_lstring(ctx : Context, obj_index : Index, key : UInt8*, length : Size) : Bool
  fun has_prop_index = duk_has_prop_index(ctx : Context, obj_Index : Index, arr_index : UInt32) : Bool
  fun def_prop = duk_def_prop(ctx : Context, obj_index : Index, flags : UInt32)
  fun get_prop_desc = duk_get_prop_desc(ctx : Context, index : Index, flags : UInt32)
  fun def_prop = duk_def_prop(ctx : Context, index : Index, flags : UInt32)
  fun get_global_string = duk_get_global_string(ctx : Context, key : UInt8*) : Bool
  fun get_global_lstring = duk_get_global_lstring(ctx : Context, key : UInt8*, length : Size) : Bool
  fun put_global_string = duk_put_global_string(ctx : Context, key : UInt8*) : Bool
  fun put_global_lstring = duk_put_global_lstring(ctx : Context, key : UInt8*, length : Size) : Bool
  fun put_global_heapptr = duk_put_global_heapptr(ctx : Context, key : Void*) : Bool

  # Inspection
  fun inspect_value = duk_inspect_value(ctx : Context, index : Index)
  fun inspect_callstack_entry = duk_inspect_callstack_entry(ctx : Context, level : Int32)

  # Object Prototype
  fun get_prototype = duk_get_prototype(ctx : Context, index : Index)
  fun set_prototype = duk_set_prototype(ctx : Context, index : Index)

  # Object Finalizer
  fun get_finalizer = duk_get_finalizer(ctx : Context, index : Index)
  fun set_finalizer = duk_set_finalizer(ctx : Context, index : Index)

  # Global Object
  fun set_global_object = duk_set_global_object(ctx : Context)

  # Duktape/C function magic value
  fun get_magic = duk_get_magic(ctx : Context, index : Index) : Int32
  fun set_magic = duk_set_magic(ctx : Context, index : Index, magic : Int32)
  fun get_current_magic = duk_get_current_magic(ctx : Context) : Int32

  # Module Helpers
  fun put_function_list = duk_put_function_lest(ctx : Context, obj_index : Index, funcs : FuncListEntry*)
  fun put_number_list = duk_put_number_list(ctx : Context, obj_index : Index, numbers : NumberListEntry*)

  # Object Operations
  fun compact = duk_compact(ctx : Context, obj_index : Index)
  fun enum = duk_enum(ctx : Context, obj_index : Index, flags : UInt32)
  fun next = duk_next(ctx : Context, index : Index, value : Bool) : Bool
  fun seal = duk_seal(ctx : Context, index : Index)
  fun freeze = duk_freeze(ctx : Context, index : Index)

  # String Manipulation
  fun concat = duk_concat(ctx : Context, count : Index)
  fun join = duk_join(ctx : Context, count : Index)
  fun decode_string = duk_decode_string(ctx : Context, index : Index, callback : Void*, udata : Void*)
  fun map_string = duk_map_string(ctx : Context, index : Index, callback : Void*, udata : Void*)
  fun substring = duk_substring(ctx : Context, index : Index, start_idx : Size, end_idx : Size)
  fun trim = duk_trim(ctx : Context, index : Index)
  fun char_code_at = duk_char_code_at(ctx : Context, index : Index, offset : Size) : Int32

  # ECMAScript Operators
  fun equals = duk_equals(ctx : Context, one : Index, two : Index) : Bool
  fun strict_equals = duk_strict_equals(ctx : Context, one : Index, two : Index) : Bool
  fun samevalue = duk_samevalue(ctx : Context, one : Index, two : Index) : Bool
  fun instanceof = duk_instanceof(ctx : Context, one : Index, two : Index) : Bool

  # Random
  fun random = duk_random(ctx : Context) : Number

  # Method Calls
  fun call = duk_call(ctx : Context, nargs : Index)
  fun call_method = duk_call_method(ctx : Context, nargs : Index)
  fun call_prop = duk_call_prop(ctx : Context, index : Index, nargs : Index)
  fun pcall = duk_pcall(ctx : Context, nargs : Index) : Int32
  fun pcall_method = duk_pcall_method(ctx : Context, nargs : Index) : Int32
  fun pcall_prop = duk_pcall_prop(ctx : Context, obj_index : Index, nargs : Index) : Int32
  fun new = duk_new(ctx : Context, nargs : Index)
  fun pnew = duk_pnew(ctx : Context, nargs : Index) : Int32
  fun safe_call = duk_safe_call(ctx : Context, func : Context -> Int32, udata : Void*, nargs : Index, nrets : Index) : Int32

  # Compilation and Evaluation
  fun eval_raw = duk_eval_raw(ctx : Context, src_buffer : UInt8*, src_length : Size, flags : UInt32) : Int32
  fun compile_raw = duk_compile_raw(ctx : Context, src_buffer : UInt8*, src_length : Size, flags : UInt32) : Int32
  fun dump_function = duk_dump_function(ctx : Context)
  fun load_function = duk_load_function(ctx : Context)

  # Debugging
  fun push_context_dump = duk_push_context_dump(ctx : Context)

  # Debug Protocol
  fun debugger_attach = duk_debugger_attach(ctx : Context, read : Void*, write : Void*, peek : Void*, read_flush : Void*, write_flush : Void*, detached : Void*, udata : Void*)
  fun debugger_detach = duk_debug_detach(ctx : Context)
  fun debugger_cooperate = duk_debugger_cooperate(ctx : Context)
  fun debugger_notify = duk_debugger_notify(ctx : Context, nvalues : Index) : Bool
  fun debugger_pause = duk_debugger_pause(ctx : Context)

  # Time Handling
  fun get_now = duk_get_now(ctx : Context) : Number
  fun time_to_components = duk_time_to_components(ctx : Context, timeval : Number, components : TimeComponents*)
  fun components_to_time = duk_components_to_time(ctx : Context, components : TimeComponents*) : Number
end
