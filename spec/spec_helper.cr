ENV["CRYSTAL_PATH"] = "#{__DIR__}/../src"
ENV["VERIFY"] = "1"

require "spec"
require "../src/lib_duktape"
require "../src/duktape"
require "./support/**"

JS_SOURCE_PATH = "#{__DIR__}/javascripts"

REFERENCE_REGEX = /identifier '__abc__' undefined/
SYNTAX_REGEX    = /unterminated string/
TYPE_REGEX      = /undefined not callable/
