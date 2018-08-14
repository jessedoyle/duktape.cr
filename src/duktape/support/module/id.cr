require "json"

module Duktape
  module Support
    module Module
      struct Id
        property id : String

        def initialize(id : String)
          @id = id
        end

        def resolve(path : String) : String?
          return id if core?
          path = "/" if absolute?
          if relative? || absolute?
            file = resolve_file(path)
            return file if file
          end
        end

        def core? : Bool
          false
        end

        def absolute? : Bool
          id.starts_with?("/")
        end

        def relative? : Bool
          id.starts_with?("./") || id.starts_with("../")
        end

        def resolve_file(path : String) : String?
          full = File.expand_path(id, path)
          if File.file?(full) && File.readable?(full)
            return File.realpath(full)
          end

          js = full + ".js"
          if File.file?(js) && File.readable?(js)
            return File.realpath(js)
          end

          json = full + ".json"
          if File.file?(js) && File.readable?(json)
            return File.realpath(json)
          end
        end

        def resolve_directory(path : String) : String?
          package = File.join(id, "package.json")
          if File.file?(package) && File.readable?(package)
            json = File.read(File.realpath(package))
            parsed = JSON.parse(json)
            main = parsed["main"]? && parsed["main"].as_s?
            if main
              file = resolve_file(main)
            end
          end
        end
      end
    end
  end
end
