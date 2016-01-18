# lib_duktape.cr: crystal bindings for duktape
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

@[Link(ldflags: "-L#{__DIR__}/.build/lib -L#{__DIR__}/.build/include -lduktape -lm")]
lib LibDUK
  alias Context = Void*

  BUF_FLAG_DYNAMIC  = 1_u32
  BUF_FLAG_EXTERNAL = 2_u32
  BUF_FLAG_NOZERO   = 4_u32

  BUF_MODE_FIXED    = 0_u32
  BUF_MODE_DYNAMIC  = 1_u32
  BUF_MODE_DONTCARE = 2_u32

  BUFOBJ_CREATE_ARRBUF     = 16_u32
  BUFOBJ_DUKTAPE_BUFFER    =  0_u32
  BUFOBJ_NODEJS_BUFFER     =  1_u32
  BUFOBJ_ARRAY_BUFFER      =  2_u32
  BUFOBJ_DATAVIEW          = (3_u32 | BUFOBJ_CREATE_ARRBUF)
  BUFOBJ_INT8ARRAY         = (4_u32 | BUFOBJ_CREATE_ARRBUF)
  BUFOBJ_UINT8ARRAY        = (5_u32 | BUFOBJ_CREATE_ARRBUF)
  BUFOBJ_UINT8CLAMPEDARRAY = (6_u32 | BUFOBJ_CREATE_ARRBUF)
  BUFOBJ_INT16ARRAY        = (7_u32 | BUFOBJ_CREATE_ARRBUF)
  BUFOBJ_UINT16ARRAY       = (8_u32 | BUFOBJ_CREATE_ARRBUF)
  BUFOBJ_INT32ARRAY        = (9_u32 | BUFOBJ_CREATE_ARRBUF)
  BUFOBJ_UINT32ARRAY       = (10_u32 | BUFOBJ_CREATE_ARRBUF)
  BUFOBJ_FLOAT32ARRAY      = (11_u32 | BUFOBJ_CREATE_ARRBUF)
  BUFOBJ_FLOAT64ARRAY      = (12_u32 | BUFOBJ_CREATE_ARRBUF)

  COMPILE_EVAL     = 0x01_u32
  COMPILE_FUNCTION = 0x02_u32
  COMPILE_STRICT   = 0x04_u32
  COMPILE_SAFE     = 0x08_u32
  COMPILE_NORESULT = 0x10_u32
  COMPILE_NOSOURCE = 0x20_u32
  COMPILE_STRLEN   = 0x40_u32

  DEFPROP_WRITABLE          =   1_u32
  DEFPROP_ENUMERABLE        =   2_u32
  DEFPROP_CONFIGURABLE      =   4_u32
  DEFPROP_HAVE_WRITABLE     =   8_u32
  DEFPROP_HAVE_ENUMERABLE   =  16_u32
  DEFPROP_HAVE_CONFIGURABLE =  32_u32
  DEFPROP_HAVE_VALUE        =  64_u32
  DEFPROP_HAVE_GETTER       = 128_u32
  DEFPROP_HAVE_SETTER       = 256_u32
  DEFPROP_FORCE             = 512_u32

  ENUM_INCLUDE_NONENUMERABLE =  1_u32
  ENUM_INCLUDE_INTERNAL      =  2_u32
  ENUM_OWN_PROPERTIES_ONLY   =  4_u32
  ENUM_ARRAY_INDICIES_ONLY   =  8_u32
  ENUM_SORT_ARRAY_INDICIES   = 16_u32
  ENUM_NO_PROXY_BEHAVIOR     = 32_u32

  # Internal Error Codes
  ERR_NONE                =  0
  ERR_UNIMPLEMENTED_ERROR = 50
  ERR_UNSUPPORTED_ERROR   = 51
  ERR_INTERNAL_ERROR      = 52
  ERR_ALLOC_ERROR         = 53
  ERR_ASSERTION_ERROR     = 54
  ERR_API_ERROR           = 55
  ERR_UNCAUGHT_ERROR      = 56

  EXEC_SUCCESS = 0
  EXEC_ERROR   = 1

  # ECMAScript Error Codes
  ERR_ERROR           = 100
  ERR_EVAL_ERROR      = 101
  ERR_RANGE_ERROR     = 102
  ERR_REFERENCE_ERROR = 103
  ERR_SYNTAX_ERROR    = 104
  ERR_TYPE_ERROR      = 105
  ERR_URI_ERROR       = 106

  INVALID_INDEX = Int32::MIN

  HINT_NONE   = 0
  HINT_STRING = 1
  HINT_NUMBER = 2

  THREAD_NEW_GLOBAL_ENV = 1_u32

  TYPE_NONE      = 0
  TYPE_UNDEFINED = 1
  TYPE_NULL      = 2
  TYPE_BOOLEAN   = 3
  TYPE_NUMBER    = 4
  TYPE_STRING    = 5
  TYPE_OBJECT    = 6
  TYPE_BUFFER    = 7
  TYPE_POINTER   = 8
  TYPE_LIGHTFUNC = 9

  TYPE_MASK_NONE      = (1 << TYPE_NONE).to_u32
  TYPE_MASK_UNDEFINED = (1 << TYPE_UNDEFINED).to_u32
  TYPE_MASK_NULL      = (1 << TYPE_NULL).to_u32
  TYPE_MASK_BOOLEAN   = (1 << TYPE_BOOLEAN).to_u32
  TYPE_MASK_NUMBER    = (1 << TYPE_NUMBER).to_u32
  TYPE_MASK_STRING    = (1 << TYPE_STRING).to_u32
  TYPE_MASK_OBJECT    = (1 << TYPE_OBJECT).to_u32
  TYPE_MASK_BUFFER    = (1 << TYPE_BUFFER).to_u32
  TYPE_MASK_POINTER   = (1 << TYPE_POINTER).to_u32
  TYPE_MASK_LIGHTFUNC = (1 << TYPE_LIGHTFUNC).to_u32
  TYPE_MASK_THROW     = (1 << 10).to_u32

  VARARGS = -1_i32

  struct TimeoutData
    start : LibC::TimeVal
    timeout : LibC::TimeVal
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
    value : Float64
  end

  # Memory Functions
  fun alloc = duk_alloc(ctx : Context, size : Int32) : Void*
  fun alloc_raw = duk_alloc_raw(ctx : Context, size : Int32) : Void*
  fun free = fuk_free(ctx : Context, ptr : Void*)
  fun free_raw = duk_free_raw(ctx : Context, ptr : Void*)
  fun gc = duk_gc(ctx : Context, flags : UInt32)
  fun get_memory_functions = duk_get_memory_functions(ctx : Context, out_func : MemoryFunctions*)
  fun realloc = duk_realloc(ctx : Context, ptr : Void*, size : Int32) : Void*
  fun realloc_raw = duk_realloc_raw(ctx : Context, ptr : Void*, size : Int32) : Void*

  # Context Management
  fun create_heap = duk_create_heap(alloc_func : Void*, realloc_func : Void*, free_func : Void*, heap_data : Void*, fatal_func : Void*) : Context
  fun destroy_heap = duk_destroy_heap(ctx : Context)

  # Error Handling
  @[Raises]
  fun throw = duk_throw(ctx : Context)
  @[Raises]
  fun fatal = duk_fatal(ctx : Context, err : Int32, msg : UInt8*)
  @[Raises]
  fun error_raw = duk_error_raw(ctx : Context, err : Int32, file : UInt8*, line : Int32, fmt : UInt8*, ...)
  fun error_stash = duk_error_stash(ctx : Context, err : Int32, fmt : UInt8*, ...)
  fun get_error_code = duk_get_error_code(ctx : Context, index : Int32) : Int32

  # State-related
  fun is_strict_call = duk_is_strict_call(ctx : Context) : Int32
  fun is_constructor_call = duk_is_constructor_call(ctx : Context) : Int32

  # Stack Management
  fun normalize_index = duk_normalize_index(ctx : Context, index : Int32) : Int32
  fun require_normalize_index = duk_require_normalize_index(ctx : Context, index : Int32) : Int32
  fun is_valid_index = duk_is_valid_index(ctx : Context, index : Int32) : Int32
  fun require_valid_index = duk_require_valid_index(ctx : Context, index : Int32)
  fun get_top = duk_get_top(ctx : Context) : Int32
  fun set_top = duk_set_top(ctx : Context, index : Int32)
  fun get_top_index = duk_get_top_index(ctx : Context) : Int32
  fun require_top_index = duk_require_top_index(ctx : Context) : Int32
  fun check_stack = duk_check_stack(ctx : Context, extra : Int32) : Int32
  fun require_stack = duk_require_stack(ctx : Context, extra : Int32)
  fun check_stack_top = duk_check_stack_top(ctx : Context, top : Int32) : Int32
  fun require_stack_top = duk_require_stack_top(ctx : Context, top : Int32)

  # Stack Manipulation
  fun swap = duk_swap(ctx : Context, idx_1 : Int32, idx_2 : Int32)
  fun swap_top = duk_swap_top(ctx : Context, index : Int32)
  fun dup = duk_dup(ctx : Context, from_index : Int32)
  fun dup_top = duk_dup_top(ctx : Context)
  fun insert = duk_insert(ctx : Context, to_index : Int32)
  fun replace = duk_replace(ctx : Context, to_index : Int32)
  fun copy = duk_copy(ctx : Context, from_index : Int32, to_index : Int32)
  fun remove = duk_remove(ctx : Context, index : Int32)
  fun xcopymove_raw = duk_xcopymove_raw(to : Context, from : Context, count : Int32, is_copy : Int32)

  # Push Operations
  fun push_undefined = duk_push_undefined(ctx : Context)
  fun push_null = duk_push_null(ctx : Context)
  fun push_boolean = duk_push_boolean(ctx : Context, val : Int32)
  fun push_true = duk_push_true(ctx : Context)
  fun push_false = duk_push_false(ctx : Context)
  fun push_number = duk_push_number(ctx : Context, val : Float64)
  fun push_nan = duk_push_nan(ctx : Context)
  fun push_int = duk_push_int(ctx : Context, val : Int32)
  fun push_uint = duk_push_uint(ctx : Context, val : UInt32)
  fun push_string = duk_push_string(ctx : Context, str : UInt8*) : UInt8*
  fun push_lstring = duk_push_lstring(ctx : Context, str : UInt8*, len : Int32) : UInt8*
  fun push_pointer = duk_push_pointer(ctx : Context, ptr : Void*)
  fun push_sprintf = duk_push_sprintf(ctx : Context, fmt : UInt8*, ...) : UInt8*
  fun push_vsprintf = duk_push_vsprintf(ctx : Context, fmt : UInt8*, ap : Void*) : UInt8*
  fun push_string_file_raw = duk_push_string_file_raw(ctx : Context, path : UInt8*, flags : UInt32) : UInt8*
  fun push_this = duk_push_this(ctx : Context)
  fun push_current_function = duk_push_current_function(ctx : Context)
  fun push_current_thread = duk_push_current_thread(ctx : Context)
  fun push_global_object = duk_push_global_object(ctx : Context)
  fun push_global_stash = duk_push_global_stash(ctx : Context)
  fun push_heap_stash = duk_push_heap_stash(ctx : Context)
  fun push_thread_stash = duk_push_thread_stash(ctx : Context, target : Context)
  fun push_object = duk_push_object(ctx : Context) : Int32
  fun push_array = duk_push_array(ctx : Context) : Int32
  fun push_c_function = duk_push_c_function(ctx : Context, func : Context -> Int32, nargs : Int32) : Int32
  fun push_c_lightfunc = duk_push_c_lightfunc(ctx : Context, func : Context -> Int32, nargs : Int32) : Int32
  fun push_thread_raw = duk_push_thread_raw(ctx : Context, flags : UInt32) : Int32
  fun push_error_object_raw = duk_push_error_object_raw(ctx : Context, err : Int32, filename : UInt8*, line : Int32, fmt : UInt8*, ...) : Int32
  fun push_error_object_stash = duk_push_error_object_stash(ctx : Context, err : Int32, fmt : UInt8*, ...) : Int32
  fun push_error_object_va_raw = duk_push_error_object_va_raw(ctx : Context, err : Int32, filename : UInt8*, line : Int32, fmt : UInt8*, ap : Void*) : Int32
  fun push_buffer_raw = duk_push_buffer_raw(ctx : Context, size : Int32, flags : UInt32) : Void*
  fun push_heapptr = duk_push_heapptr(ctx : Context, ptr : Void*) : Int32

  # Pop Operations
  fun pop = duk_pop(ctx : Context)
  fun pop_n = duk_pop_n(ctx : Context, count : Int32)
  fun pop_2 = duk_pop_2(ctx : Context)
  fun pop_3 = duk_pop_3(ctx : Context)

  # Type Checks
  fun get_type = duk_get_type(ctx : Context, index : Int32) : Int32
  fun check_type = duk_check_type(ctx : Context, index : Int32, t : Int32) : Int32
  fun get_type_mask = duk_get_type_mask(ctx : Context, index : Int32) : UInt32
  fun check_type_mask = duk_check_type_mask(ctx : Context, index : Int32, mask : UInt32) : Int32
  fun is_undefined = duk_is_undefined(ctx : Context, index : Int32) : Int32
  fun is_null = duk_is_null(ctx : Context, index : Int32) : Int32
  fun is_null_or_undefined = duk_is_null_or_undefined(ctx : Context, index : Int32) : Int32
  fun is_boolean = duk_is_boolean(ctx : Context, index : Int32) : Int32
  fun is_number = duk_is_number(ctx : Context, index : Int32) : Int32
  fun is_nan = duk_is_nan(ctx : Context, index : Int32) : Int32
  fun is_string = duk_is_string(ctx : Context, index : Int32) : Int32
  fun is_object = duk_is_object(ctx : Context, index : Int32) : Int32
  fun is_buffer = duk_is_buffer(ctx : Context, index : Int32) : Int32
  fun is_pointer = duk_is_pointer(ctx : Context, index : Int32) : Int32
  fun is_lightfunc = duk_is_lightfunc(ctx : Context, index : Int32) : Int32
  fun is_array = duk_is_array(ctx : Context, index : Int32) : Int32
  fun is_function = duk_is_function(ctx : Context, index : Int32) : Int32
  fun is_c_function = duk_is_c_function(ctx : Context, index : Int32) : Int32
  fun is_ecmascript_function = duk_is_ecmascript_function(ctx : Context, index : Int32) : Int32
  fun is_bound_function = duk_is_bound_function(ctx : Context, index : Int32) : Int32
  fun is_thread = duk_is_thread(ctx : Context, index : Int32) : Int32
  fun is_dynamic_buffer = duk_is_dynamic_buffer(ctx : Context, index : Int32) : Int32
  fun is_fixed_buffer = duk_is_fixed_buffer(ctx : Context, index : Int32) : Int32
  fun is_external_buffer = duk_is_external_buffer(ctx : Context, index : Int32) : Int32
  fun is_primitive = duk_is_primitive(ctx : Context, index : Int32) : Int32

  # Get Operations
  fun get_boolean = duk_get_boolean(ctx : Context, index : Int32) : Int32
  fun get_number = duk_get_number(ctx : Context, index : Int32) : Float64
  fun get_int = duk_get_int(ctx : Context, index : Int32) : Int32
  fun get_uint = duk_get_uint(ctx : Context, index : Int32) : UInt32
  fun get_string = duk_get_string(ctx : Context, index : Int32) : UInt8*
  fun get_lstring = duk_get_lstring(ctx : Context, index : Int32, out_len : Int32*) : UInt8*
  fun get_buffer = duk_get_buffer(ctx : Context, index : Int32, out_size : Int32*) : Void*
  fun get_pointer = duk_get_pointer(ctx : Context, index : Int32) : Void*
  fun get_c_function = duk_get_c_function(ctx : Context, index : Int32) : Void*
  fun get_context = duk_get_context(ctx : Context, index : Int32) : Context
  fun get_heapptr = duk_get_heapptr(ctx : Context, index : Int32) : Void*
  fun get_length = duk_get_length(ctx : Context, index : Int32) : Int32

  # Require Operations
  fun require_undefined = duk_require_undefined(ctx : Context, index : Int32)
  fun require_null = duk_require_null(ctx : Context, index : Int32)
  fun require_boolean = duk_require_boolean(ctx : Context, index : Int32) : Int32
  fun require_number = duk_require_number(ctx : Context, index : Int32) : Float64
  fun require_int = duk_require_int(ctx : Context, index : Int32) : Int32
  fun require_uint = duk_require_uint(ctx : Context, index : Int32) : UInt32
  fun require_string = duk_require_string(ctx : Context, index : Int32) : UInt8*
  fun require_lstring = duk_require_lstring(ctx : Context, index : Int32, out_len : Int32*) : UInt8*
  fun require_buffer = duk_require_buffer(ctx : Context, index : Int32, out_size : Int32*) : Void*
  fun require_pointer = duk_require_pointer(ctx : Context, index : Int32) : Void*
  fun require_c_function = duk_require_c_function(ctx : Context, index : Int32) : Int32
  fun require_context = duk_require_context(ctx : Context, index : Int32) : Context
  fun require_heapptr = duk_require_heapptr(ctx : Context, index : Int32) : Void*
  @[Raises]
  fun require_function = duk_require_function(ctx : Context, index : Int32)

  # Coercion Operations
  fun to_undefined = duk_to_undefined(ctx : Context, index : Int32)
  fun to_null = duk_to_null(ctx : Context, index : Int32)
  fun to_boolean = duk_to_boolean(ctx : Context, index : Int32) : Int32
  fun to_number = duk_to_number(ctx : Context, index : Int32) : Float64
  fun to_int = duk_to_int(ctx : Context, index : Int32) : Int32
  fun to_uint = duk_to_uint(ctx : Context, index : Int32) : UInt32
  fun to_int32 = duk_to_int32(ctx : Context, index : Int32) : Int32
  fun to_uint32 = duk_to_uint32(ctx : Context, index : Int32) : UInt32
  fun to_uint16 = duk_to_uint16(ctx : Context, index : Int32) : UInt16
  fun to_string = duk_to_string(ctx : Context, index : Int32) : UInt8*
  fun to_lstring = duk_to_lstring(ctx : Context, index : Int32, out_len : Int32*) : UInt8*
  fun to_buffer_raw = duk_to_buffer_raw(ctx : Context, index : Int32, out_size : Int32*, flags : UInt32) : Void*
  fun to_pointer = duk_to_pointer(ctx : Context, index : Int32) : Void*
  fun to_object = duk_to_object(ctx : Context, index : Int32)
  fun to_defaultvalue = duk_to_defaultvalue(ctx : Context, index : Int32, hint : Int32)
  fun to_primitive = duk_to_primitive(cts : Context, index : Int32, hint : Int32)
  fun safe_to_lstring = duk_safe_to_lstring(ctx : Context, index : Int32, out_len : Int32*) : UInt8*

  # Misc Conversion
  fun base64_encode = duk_base64_encode(ctx : Context, index : Int32) : UInt8*
  fun base64_decode = duk_base64_decode(ctx : Context, index : Int32)
  fun hex_encode = duk_hex_encode(ctx : Context, index : Int32) : UInt8*
  fun hex_decode = duk_hex_decode(ctx : Context, index : Int32)
  fun json_encode = duk_json_encode(ctx : Context, index : Int32) : UInt8*
  fun json_decode = duk_json_decode(ctx : Context, index : Int32)

  # Buffer Operations
  fun config_buffer = duk_config_buffer(ctx : Context, index : Int32, ptr : Void*, len : Int32)
  fun get_buffer_data = duk_get_buffer_data(ctx : Context, index : Int32, out_size : Int32*) : Void*
  fun push_buffer_object = duk_push_buffer_object(ctx : Context, index : Int32, offset : Int32, byte_length : Int32, flags : UInt32)
  fun resize_buffer = duk_resize_buffer(ctx : Context, index : Int32, new_size : Int32) : Void*
  fun steal_buffer = duk_steal_buffer(ctx : Context, index : Int32, out_size : Int32*) : Void*

  # Property Access
  fun get_prop = duk_get_prop(ctx : Context, obj_index : Int32) : Int32
  fun get_prop_string = duk_get_prop_string(ctx : Context, obj_index : Int32, key : UInt8*) : Int32
  fun get_prop_index = duk_get_prop_index(ctx : Context, obj_index : Int32, arr_index : UInt32) : Int32
  fun put_prop = duk_put_prop(ctx : Context, obj_index : Int32) : Int32
  fun put_prop_string = duk_put_prop_string(ctx : Context, obj_index : Int32, key : UInt8*) : Int32
  fun put_prop_index = duk_put_prop_index(ctx : Context, obj_index : Int32, arr_index : UInt32) : Int32
  fun del_prop = duk_del_prop(ctx : Context, obj_index : Int32) : Int32
  fun del_prop_string = duk_del_prop_string(ctx : Context, obj_index : Int32, key : UInt8*) : Int32
  fun del_prop_index = duk_del_prop_index(ctx : Context, obj_index : Int32, arr_index : UInt32) : Int32
  fun has_prop = duk_has_prop(ctx : Context, obj_index : Int32) : Int32
  fun has_prop_string = duk_has_prop_string(ctx : Context, obj_index : Int32, key : UInt8*) : Int32
  fun has_prop_index = duk_has_prop_index(ctx : Context, obj_Index : Int32, arr_index : UInt32) : Int32
  fun def_prop = duk_def_prop(ctx : Context, obj_index : Int32, flags : UInt32)
  fun get_global_string = duk_get_global_string(ctx : Context, key : UInt8*) : Int32
  fun put_global_string = duk_put_global_string(ctx : Context, key : UInt8*) : Int32

  # Object Prototype
  fun get_prototype = duk_get_prototype(ctx : Context, index : Int32)
  fun set_prototype = duk_set_prototype(ctx : Context, index : Int32)

  # Object Finalizer
  fun get_finalizer = duk_get_finalizer(ctx : Context, index : Int32)
  fun set_finalizer = duk_set_finalizer(ctx : Context, index : Int32)

  # Global Object
  fun set_global_object = duk_set_global_object(ctx : Context)

  # Duktape/C function magic value
  fun get_magic = duk_get_magic(ctx : Context, index : Int32) : Int32
  fun set_magic = duk_set_magic(ctx : Context, index : Int32)
  fun get_current_magic = duk_get_current_magic(ctx : Context) : Int32

  # Module Helpers
  fun put_function_list = duk_put_function_lest(ctx : Context, obj_index : Int32, funcs : FuncListEntry*)
  fun put_number_list = duk_put_number_list(ctx : Context, obj_index : Int32, numbers : NumberListEntry*)

  # Variable Access
  fun get_var = duk_get_var(ctx : Context)
  fun put_var = duk_put_var(ctx : Context)
  fun del_var = duk_del_var(ctx : Context) : Int32
  fun has_var = duk_has_var(ctx : Context) : Int32

  # Object Operations
  fun compact = duk_compact(ctx : Context, obj_index : Int32)
  fun enum = duk_enum(ctx : Context, obj_index : Int32, flags : UInt32)
  fun next = duk_next(ctx : Context, index : Int32, value : Int32) : Int32

  # String Manipulation
  fun concat = duk_concat(ctx : Context, count : Int32)
  fun join = duk_join(ctx : Context, count : Int32)
  fun decode_string = duk_decode_string(ctx : Context, index : Int32, callback : Void*, udata : Void*)
  fun map_string = duk_map_string(ctx : Context, index : Int32, callback : Void*, udata : Void*)
  fun substring = duk_substring(ctx : Context, index : Int32, start_idx : Int32, end_idx : Int32)
  fun trim = duk_trim(ctx : Context, index : Int32)
  fun char_code_at = duk_char_code_at(ctx : Context, index : Int32, offset : Int32) : Int32

  # ECMAScript Operators
  fun equals = duk_equals(ctx : Context, one : Int32, two : Int32) : Int32
  fun instanceof = duk_instanceof(ctx : Context, one : Int32, two : Int32) : Int32
  fun strict_equals = duk_strict_equals(ctx : Context, one : Int32, two : Int32) : Int32

  # Method Calls
  fun call = duk_call(ctx : Context, nargs : Int32)
  fun call_method = duk_call_method(ctx : Context, nargs : Int32)
  fun call_prop = duk_call_prop(ctx : Context, index : Int32, nargs : Int32)
  fun pcall = duk_pcall(ctx : Context, nargs : Int32) : Int32
  fun pcall_method = duk_pcall_method(ctx : Context, nargs : Int32) : Int32
  fun pcall_prop = duk_pcall_prop(ctx : Context, obj_index : Int32, nargs : Int32) : Int32
  fun new = duk_new(ctx : Context, nargs : Int32)
  fun pnew = duk_pnew(ctx : Context, nargs : Int32) : Int32
  fun safe_call = duk_safe_call(ctx : Context, func : Context -> Int32, nargs : Int32, nrets : Int32) : Int32

  # Compilation and Evaluation
  fun eval_raw = duk_eval_raw(ctx : Context, src_buffer : UInt8*, src_length : Int32, flags : UInt32) : Int32
  fun compile_raw = duk_compile_raw(ctx : Context, src_buffer : UInt8*, src_length : Int32, flags : UInt32) : Int32
  fun dump_function = duk_dump_function(ctx : Context)
  fun load_function = duk_load_function(ctx : Context)

  # Logging
  fun log = duk_log(ctx : Context, level : Int32, fmt : UInt8*, ...)
  fun log_va = duk_log_va(ctx : Context, level : Int32, fmt : UInt8*, ap : Void*)

  # Debugging
  fun push_context_dump = duk_push_context_dump(ctx : Context)

  # Debug Protocol
  fun debugger_attach = duk_debugger_attach(ctx : Context, read : Void*, write : Void*, peek : Void*, read_flush : Void*, write_flush : Void*, detached : Void*, udata : Void*)
  fun debugger_detach = duk_debug_detach(ctx : Context)
  fun debugger_cooperate = duk_debugger_cooperate(ctx : Context)
end
