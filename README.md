# Duktape.cr

[![Build Status](https://travis-ci.org/jessedoyle/duktape.cr.svg?branch=master)](https://travis-ci.org/jessedoyle/duktape.cr)

Duktape.cr provides Crystal bindings to the [Duktape](https://github.com/svaarala/duktape) javascript engine.

## Installation

Duktape.cr is best installed using either [Shards](https://github.com/ysbaddaden/shards) or the Crystal Package Manager.

### Via Crystal Package Manager

Add this to your `Projectfile`:

```crystal
deps do
  github "jessedoyle/duktape.cr", name: "duktape"
end
```

then execute:

```bash
crystal deps
```

Finally build the native Duktape library:

```bash
make -C libs/duktape/ext libduktape
```

### Via Shards

Add this to your `shard.yml`:

```yaml
name: example  # your project's name
version: 1.0.0 # your project's version

dependencies:
  duktape:
    github: jessedoyle/duktape.cr
    branch: master
```

then execute:

```bash
shards install
```

Note that Shards `v0.3.1` or greater will automatically make the native library. Otherwise you will have to make the library manually by calling `make libduktape` from `libs/duktape/ext`.

## Usage

You must first create a Duktape context:

```crystal
require "duktape"

sbx = Duktape::Sandbox.new

sbx.eval! <<-JS
  var birthYear = 1990;

  function calcAge(birthYear){
    var current = new Date();
    var year = current.getFullYear();
    return year - birthYear;
  }

  print("You are " + calcAge(birthYear) + " years old.");
JS
```

An overwhelming majority of the [Duktape API](http://duktape.org/api.html) has been implemented. You can call the API functions directly on a `Duktape::Sandbox` or `Duktape::Context` instance:

```crystal
sbx = Duktape::Sandbox.new
sbx.push_global_object   # [ global ]
sbx.push_string "Math"   # [ global "Math" ]
sbx.get_prop -2          # [ global Math ]
sbx.push_string "PI"     # [ global Math "PI" ]
sbx.get_prop -2          # [ global Math PI ]
pi = sbx.get_number -1
puts "PI: #{pi}"
sbx.pop_3
```

## Eval vs Eval!

All of the evaluation API methods have a corresponding bang-method (`!`). The bang method calls will raise when a javascript error occurs, the non-bang methods will not raise on invalid javascript.

For example:

```crystal
sbx = Duktape::Context.new
sbx.eval <<-JS
  var a =
JS
```

will not raise any errors, but will return a non-zero error code.

The following code:

```crystal
sbx = Duktape::Context.new
sbx.eval! <<-JS
  __invalid();
JS
```

will raise `Duktape::Error "SyntaxError"`.

## Sandbox vs Context

You should only execute untrusted javascript code on from within a `Duktape::Sandbox` instance. A sandbox isolates code from insecure operations such as Duktape's internal `require` mechanism and the `Duktape` global javascript object.

Note that a sandbox does not currently protect against infinite loops or excessive runtime. Ideally, a timeout mechanism will be available in future releases.

Creating a `Duktape::Context` gives code access to internal Duktape properties:

```crystal
ctx = Duktape::Context.new
ctx.eval! <<-JS
  print(Duktape.version);
JS
```

## Calling Crystal Code from Javascript

Note: This functionality is considered experimental and syntax/functionality may change dramatically between releases.

It is possible to call Crystal code from your javascript:

```crystal
  sbx = Duktape::Context.new

  sbx.push_proc(2) do |ptr| # 2 stack arguments
    env = Duktape::Sandbox.new ptr
    a = env.get_number 0
    b = env.get_number 1
    env.push_int a + b
    env.return 1 # return success
  end

  sbx.push_int 2
  sbx.push_int 3
  sbx.call 2 # 2 stack arguments
  val = sbx.get_int -1
  puts val #=> 5
```

## Contributing

I'll accept any pull requests that are well tested for bugs/features with Duktape.cr.

You should fork the main repo, create a feature branch, write tests and submit a pull request.

## License

Duktape.cr is licensed under the MIT License. Please see `LICENSE` for details.
