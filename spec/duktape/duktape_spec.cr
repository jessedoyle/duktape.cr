require "../spec_helper"

describe Duktape do
  describe "self.version" do
    it "should not have an empty version string" do
      Duktape.version.should_not eq("")
    end
  end

  describe "self.api_version" do
    it "should not have an empty version string" do
      Duktape.api_version.should_not eq("")
    end
  end

  describe "self.create_heap_default" do
    it "should allocate a LibDUK::Context" do
      ctx = Duktape.create_heap_default

      ctx.class.should eq(LibDUK::Context)
    end
  end
end

describe "CoffeeScript" do
  it "should eval coffeescript" do
    ctx = Duktape::Context.new
    ctx.eval! File.read("#{JS_SOURCE_PATH}/coffeescript.js")
    ctx.eval_string! <<-JS
      CoffeeScript.eval("((x) -> x * x)(8)");
    JS
    ret = ctx.get_int -1

    ret.should eq(64)
  end
end

describe "UglifyJS" do
  it "should uglify some javascript" do
    ctx = Duktape::Context.new
    ctx.eval! File.read("#{JS_SOURCE_PATH}/uglify.js")
    ctx.eval_string <<-JS
      uglify('function add(x, y) {  return x + y;  }');
    JS
    ret = ctx.get_string -1

    ret.should eq("function add(x,y){return x+y}")
  end
end
