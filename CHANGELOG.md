# v1.0.1 - Oct 22, 2022

* Fix a segfault that occurs on Crystal >= 1.6.0. Thanks @z64!, #74

# v1.0.0 - April 2, 2021

* Specify a `crystal` constraint of `>= 0.35.1` for compatibility with Crystal 1.0.0. Thanks @Kanezoh!

# v0.21.0 - June 22, 2020

* **breaking change**: Rename the `CRYSTAL_LOG_LEVEL` and `CRYSTAL_LOG_SOURCES` environment variables to `LOG_LEVEL` and `LOG_SOURCES` respectively to match changes in Crystal core.
* Support Crystal >= 0.35.1.

# v0.20.0 - April 13, 2020

* **breaking change**: Remove the `Duktape::Logger` module and constants.
* **breaking change**: Remove the `Duktape.logger` and `Duktape.headerize` class methods.
* **breaking change**: Alert messages are no longer written to STDERR. Instead they are written to STDOUT.
* Upgrade for Crystal 0.34 support! A minimum crystal version of 0.34 is required for this release.
* Add the `Duktape::Log` with the `Base`, `Alert` and `Console` constants that act as sources for general log messages, alert messages, and console messages.
* Log messages are no longer colorized by default.
* Log output can be controlled using the newly-standardized `CRYSTAL_LOG_SOURCES` and `CRYSTAL_LOG_LEVEL` environment variables.
* Log output messages are now formatted by default as JSON with the following schema:

```graphql
{
  exception : String?,
  message : String,
  severity : String,
  source : String,
  timestamp : String
}
```

# v0.19.1 - March 3, 2020

- **Bugfix**: Call function properties when using `Duktape::Runtime#call` with no function arguments. [PR 58](https://github.com/jessedoyle/duktape.cr/pull/58), [Issue 57](https://github.com/jessedoyle/duktape.cr/issues/57). Thanks @dinh for reporting!

# v0.19.0 - Jan 17, 2020

- Update Duktape version to `2.5.0`.
- See the [release notes](https://github.com/svaarala/duktape/blob/1fd2171840a88cc89e7a86b84d4d051940b1c654/doc/release-notes-v2-5.rst) for more info.
- Add bindings for the `pull` API function.

# v0.18.1 - Sept 24, 2019

- Update for Crystal v0.31.0 support.
- Fix test cases that were failing because Crystal's Spec library now executes `it` blocks at the end of the program (https://github.com/crystal-lang/crystal/pull/8125). Instead of manually destroying the Duktape head in specs, let the GC take care of it.
- Update `ameba` to 0.10.1.

# v0.18.0 - Sept 6, 2019

- Update Duktape version to `2.4.0`.
- See the [release notes](https://github.com/svaarala/duktape/blob/bcb37439d6b0a589707f4d611962d7381868dce4/doc/release-notes-v2-4.rst) for more info.
- Add bindings for `to_stacktrace`, `safe_to_stacktrace`, `push_bare_array`, `require_constructable`, and `require_constructor_call`.
- Allow C compiler flag overrides when compiling Duktape. Define the `CFLAGS` variable during `shards install` (i.e. `CFLAGS=-O1 shards install`).
- No longer explicitly enable Duktape's Symbol builtin as it is now enabled by default.

# v0.17.0 - June 6, 2019

- Update `ameba` to the latest current version (`0.10.0`) as previous versions no longer compile in CI.
- Relax the restriction on `ameba` to pull in newer minor versions.

# v0.16.0 - Apr, 21 2019

- Update `ameba` to the current latest version of `v0.9.1`.
- Build specs with all warnings enabled in Crystal >= `0.28.0`.
- Fix a deprecation warning with Crystal `0.28.0` where integer division will return a float in future versions. Use `Int#//` to retain backwards compatibility.

# v0.15.1 - Nov 7, 2018

- Add [ameba](https://github.com/veelenga/ameba) as a development dependency for static analysis.
- Fix `ameba` lint exceptions consisting of unused variable definitions and block variables.

# v0.15.0 - Aug 14, 2018

- Update Duktape version to `2.3.0`.
- See the [release notes](https://github.com/svaarala/duktape/blob/5a6f30caabc8a856b113577fffd3468e8dfab621/doc/release-notes-v2-3.rst) for more info.
- Fix a missing `it` block expectation in tests.
- Add bindings for `random`, `push_new_target`, `get_global_heaptr` and `put_global_heapptr`.

# v0.14.1 - May 13, 2018

- Fix a type inference error on the Sandbox `@timeout` instance variable that occurs due to recent changes in Crystal master [#43]. Thanks @kostya!

# v0.14.0 - Apr 30, 2018

- Update Duktape to version `2.2.1`.
- See the [release](https://github.com/svaarala/duktape/blob/master/RELEASES.rst#221-2018-04-26) for more info.

# v0.13.0 - Dec 28, 2017

- Update Duktape to version `2.2.0`, rebuilding all necessary
  configuration and header files.
- [**upstream change**]
  `LibDUK::Compile::*` and `LibDUK::BufObj::*` constant values have
  been changed - remap these constants to their updated values.
- [**upstream change**]
  `LibDUK::Bool` is now of type `UInt32` (as opposed to `Int32`).
- Add bindings for new public API methods:
  `duk_pus_proxy`, `duk_seal`, `duk_freeze`, `duk_require_object`, `duk_is_constructable`
  and `duk_opt_xxx` methods. The `duk_opt` methods work similar to
  `duk_require_xxx`, but allow a default value to be passed in that
  is used when there is no value at the given stack index.
- Alias `LibDUK::Number` as `Float64` for more simple type changes in
  the future.
- Add the `Duktape::API::Opt` module to encapsulate binding wrapper code
  for the `duk_opt` methods implemented.
- Run all code through the crystal `0.24.1` formatter.
- See [duktape releases](https://github.com/svaarala/duktape/blob/master/RELEASES.rst) for more info.

# v0.12.1 - Nov 2, 2017

- [_bugfix_] - Fix an unintended `Duktape` heap instantiation when creating a new `Duktape::Context`.
- Run `crystal tool format` on all source code.

# v0.12.0 - Oct 2017

- [**breaking change**] All `LibDUK` hardcoded types are now `enum` values (i.e. `LibDUK::TYPE_NULL` becomes `LibDUK::Type::Null`). Where possible, methods accept both the original types as well as enumerated values.
- [**breaking change**] Remove the `UInt32 flags` arguments from all `Duktape::Context#compile` methods.
- [**breaking change**] Remove some bindings from `LibDUK` as they were removed upstream. See [duktape releases](https://github.com/svaarala/duktape/blob/master/RELEASES.rst) for more info.
- Update Duktape to `v2.0.2`.
- Add `Duktape::Builtin` helpers that allow for modular extensions into a `Duktape::Context` instance.
- Add builtins for `console.log`, `alert` and `print`.
- Implement file operations natively in Crystal as they have been removed from Duktape.
- The Duktape stack is no longer logged as a debug value when `Duktape::InternalError` is raised.
- Alias `Int32` as `LibDUK::Index` to allow for quicker changes to indexes in the future.

# v0.11.0 - July 24, 2017

- Fix compiler issues with Crystal `0.23.0` by making `Duktape::Logger#log_color` accept a `Logger::Severity`. [@kostya, #35]

# v0.10.1 - Jan 31, 2017

- Fix an incorrect type restriction that was causing
  compiler issues on recent Crystal versions.
- Fix Sandbox timeout tests by no longer running
  a set number of iterations - instead infinite loop
  until timeout.

# v0.10.0 - Nov 22, 2016

- Update for Crystal 0.20.0. As shards now copies
  the entire shard directory into `libs`, we can
  move the `ext` directory to the shard root directory
  for simplicity.
- Update makefile output paths to match new structure.
- Resolve [#25](https://github.com/jessedoyle/duktape.cr/issues/25)
  by allowing a developer to pass a `Duktape::Context` instance when
  initializing a `Duktape::Runtime`. This allows the runtime to
  use the internal `Duktape` global object.

# v0.9.1 - Sept 21, 2016

- Update Duktape to `v1.5.1`. See [release info](https://github.com/svaarala/duktape/blob/master/RELEASES.rst).

# v0.9.0 - May 26, 2016

- Update Duktape to `v1.5.0`. See [release info](https://github.com/svaarala/duktape/blob/master/RELEASES.rst).
- Update to Crystal `0.17.4` syntax.
- Format code using Crystal `0.17.4` formatter.
- Add `NamedTuple` as a type that is allowed as parameter to `call` on a `Duktape::Runtime` instance. NamedTuples will be translated to a hash.
- Optimize for speed (-O2) instead of size (-0s) when building the duktape library.
- Use -Wpedantic as the compiler flag for warnings.

# v0.8.2 - May 5, 2016

- Update to Crystal `0.16.0` syntax.

# v0.8.1 - Mar 23, 2016

- Update to Crystal `0.14.2` syntax.
- Refactor `API::Eval` code for readability.

# v0.8.0 - Feb 4, 2016

- (_breaking change_) JS errors are now mapped to their proper Crystal exceptions. i.e. JS `SyntaxError` becomes `Duktape::SyntaxError`.
- (_breaking change_) Make all exception classes more consistent. Instances of `Duktape::Error` are all recoverable exceptions that are thrown by the engine at runtime (eg. `Duktape::TypeError`). Instances of `Duktape::InternalError` are generally non-recoverable for a given context (eg. `Duktape::HeapError`).
- Added `call_success`, `call_failure` and `return_undefined` convenience methods that provide the appropriate integer status codes when returning from a native function call.
- Added the `push_global_proc` method that simplifies pushing a named native function to the stack.
- `Duktape::Runtime` instances may now accept a execution timeout value in milliseconds upon creation. [[#15](https://github.com/jessedoyle/duktape.cr/pull/15), [@raydf](https://github.com/raydf)].
- Changed the name in the `shard.yml` from `duktape.cr` to `duktape`. This should have no effect on the installation process.

# v0.7.0 - Jan 18, 2016

- (_breaking change_) A monkeypatch to the Crystal `Logger` class was temporarily added to master to fix a bug in core Crystal ([#1982](https://github.com/manastech/crystal/issues/1982)). This patch has now been removed from the codebase. Crystal `v0.10.1` or higher is a requirement for this library.
- `Duktape::Runtime` instances now return Crystal arrays and hashes for corresponding JS arrays and objects.
- `Duktape::Runtime` can now accept hashes and arrays as arguments for call. These will be translated into Javascript objects and pushed to the stack.
- Updated Duktape version to `v1.4.0`. See [release info](https://github.com/svaarala/duktape/blob/master/RELEASES.rst).

# v0.6.4 - Jan 2, 2016

- Add the `src/runtime.cr` file so you can now properly `require "./duktape/runtime"` once `shards` does its thing.
- Actually update the version in `shard.yml` (my mistake - sorry!).

# v0.6.3 - Jan 2, 2016

**NOTE - This release has issues, use `0.6.4` instead.**

- Rework the internal require order and `duktape/base`.
- Add a `Duktape::Runtime` class that lessens the need for low-level API calls for many use-cases. This must be required using `require "duktape/runtime"`.

# v0.6.2 - November 30, 2015

- Update Duktape version to `v1.3.1`. See [release info](https://github.com/svaarala/duktape/blob/master/RELEASES.rst).
- More consistent exception classes in `error.cr`.
- Removed a few unecessary method calls from spec files.
- Adopt Crystal `0.9.1` code formatting.

# v0.6.1 - September 21, 2015

- Update to Crystal `v0.8.0` syntax/compatibility.
- Fix a potential use-after-free scenario that may occur when `Context` or `Sandbox` instances were garbage-collected by Crystal.
- The Duktape heap is no longer destroyed when a `Duktape::InternalError` is thrown in Crystal. Instead, the heap will be destroyed automatically upon finalization.

# v0.6.0 - September 14, 2015

- Update Duktape to `v1.3.0`. This update does not break exisiting functionality. See [release info](https://github.com/svaarala/duktape/blob/master/RELEASES.rst).
- Implement a timeout mechanism for `Duktape::Sandbox` instances. A timeout is not specified by default.

A timeout may be specified (in milliseconds) as such:
```crystal
sbx = Duktape::Sandbox.new(500) # 500 millisecond execution limit
```

# v0.5.1 - September 11, 2015

- Add this `CHANGLEOG`.
- Fix issue [#1](https://github.com/jessedoyle/duktape.cr/issues/1) by linking against standard math library.
- Cleanup `Makefile` syntax.

# v0.5.0 - September 8, 2015

- Initial public release.
