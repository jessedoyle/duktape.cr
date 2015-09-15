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