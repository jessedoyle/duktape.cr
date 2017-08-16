# v0.12.0 - August 2017

- TODO

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
  initializing a `Dukatape::Runtime`. This allows the runtime to
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

- Intial public release.
