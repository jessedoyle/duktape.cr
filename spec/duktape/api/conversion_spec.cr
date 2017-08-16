require "../../spec_helper"

describe Duktape::API::Conversion do
  ctx = Duktape::Context.new

  describe "base64_decode" do
    it "should base64 decode the string at index" do
      ctx << "Zm9v"
      ctx.base64_decode(-1) # Coerced to buffer
      str = ctx.buffer_to_string(-1)

      str.should eq("foo")
    end

    it "should raise TypeError when not string" do
      ctx << 1

      expect_raises Duktape::TypeError, /not string/ do
        ctx.base64_decode(-1)
      end
    end
  end

  describe "base64_encode" do
    it "should base64 encode a valid string" do
      ctx << "foo"
      ctx.base64_encode(-1)
      str = ctx.to_string(-1)

      str.should eq("Zm9v")
    end
  end

  describe "hex_decode" do
    it "should hex decode a valid string" do
      ctx << "7465737420737472696e67"
      ctx.hex_decode(-1)
      str = ctx.buffer_to_string(-1)

      str.should eq("test string")
    end

    it "should raise TypeError when not string" do
      ctx << 1

      expect_raises Duktape::TypeError, /not string/ do
        ctx.hex_decode(-1)
      end
    end
  end

  describe "hex_encode" do
    it "should hex encode a valid string" do
      ctx << "foo"
      ctx.hex_encode(-1)
      str = ctx.to_string(-1)

      str.should eq("666f6f")
    end
  end

  describe "json_decode" do
    it "should json decode a valid string" do
      json = <<-JSON
        {
          "foo": 1,
          "bar": -2
        }
      JSON

      ctx << json
      ctx.json_decode -1
      str = ctx.to_string -1

      str.should eq("[object Object]")
    end
  end

  describe "json_encode" do
    it "should encode as json" do
      ctx.push_object
      ctx << 42
      ctx.put_prop_string(-2, "meaning_of_life")
      str = ctx.json_encode -1
      str.should eq("{\"meaning_of_life\":42}")
    end
  end
end
