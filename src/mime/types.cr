require "json"
require "./type"
require "./types/list"

# MIME::Types is a registry of MIME types. It is both a class (created with
# MIME::Types.new) and a default registry (loaded automatically or through
# interactions with `MIME::Types.[]``, `MIME::Types.for_filename`, `MIME::Types.for_extension`).
#
# ## The Default mime-types Registry
#
# The default mime-types registry is loaded automatically when the library
# is required (`require "mime/types"`).
#
# ## Usage
# ```
# require "mime/types"
#
# plaintext = MIME::Types["text/plain"]
# print plaintext.media_type # => "text'
# print plaintext.sub_type   # => "plain"
#
# puts plaintext.extensions.join(" ") # => "asc txt c cc h hh cpp"
#
# puts plaintext.encoding                    # => 8bit
# puts plaintext.binary?                     # => false
# puts plaintext.ascii?                      # => true
# puts plaintext.obsolete?                   # => false
# puts plaintext.registered?                 # => true
# puts plaintext == "text/plain"             # => true
# puts MIME::Type.simplified("x-appl/x-zip") # => "appl/zip"
# ```
module MIME::Types
  private REGISTRY = List.new

  private macro load(filename)
    {% json = run("../loader", filename) %}
    JSON.parse({{ json.stringify }}).each do |json|
      register Type.from_json json.to_json
    end
  end
  load "#{__DIR__}/../../data/mime-types.json"

  # Registers a new `MIME::Type`, delegating to `MIME::Type.new`
  def self.register(*args)
    REGISTRY.add *args
  end

  # Returns a list of all registered MIME::Types
  def self.registry
    REGISTRY
  end

  def self.inspect(io)
    to_s io
  end

  def self.to_s(io)
    io << "#<#{self.class}: #{registry.size} variants, #{registry.extensions.size} extensions>"
  end

  # Returns a list of MIME::Type objects, which may be empty. The optional
  # flag parameters are <tt>:complete</tt> (finds only complete MIME::Type
  # objects) and <tt>:registered</tt> (finds only MIME::Types that are
  # registered). It is possible for multiple matches to be returned for
  # either type (in the example below, 'text/plain' returns two values --
  # one for the general case, and one for VMS systems).
  #
  # ```
  # MIME::Types["text/plain"].each { |t| puts t.to_a.join(", ") }
  #
  # MIME::Types[/^image/, :complete => true].each do |t|
  #   puts t.to_a.join(", ")
  # end
  # ````
  def self.[](content_type : String, complete = false, registered = false)
    types = REGISTRY.select do |mime|
      next if complete && mime.complete?
      next if registered && mime.registered?
      content_type == "*/*" || mime.content_type == content_type
    end.map(&.dup).sort { |a, b| a.priority_compare(b) }
    List.new types
  end

  def self.[](content_type : Regex, complete = false, registered = false)
    types = REGISTRY.select do |mime|
      next if complete && mime.complete?
      next if registered && mime.registered?
      content_type == "*/*" || mime.content_type =~ content_type
    end.map(&.dup).sort { |a, b| a.priority_compare(b) }
    List.new types
  end

  # Returns the types for an `HTTP::Request` Accept header.
  def type_for_accept(request : HTTP::Request)
    request.headers["accept"].split(",").map(&.strip).map do |accept|
      accept.split(";").map(&.strip)
    end.sort_by do |parts|
      part = parts[1..-1].find { |p| p.starts_with? "q=" }
      part ? -part.split("=")[-1].strip.to_f : -1
    end.map(&.[0]).map do |content_type|
      Types[content_type]
    end.reduce do |iterator, types|
      iterator | types
    end
  end

  # Returns the types for an `HTTP::Request` Content-Type header.
  def type_for(request : HTTP::Request)
    Types[request.headers["content-type"]]
  end

  # Returns the types for an `HTTP::Client::Response` Content-Type header.
  def type_for(response : HTTP::Client::Response)
    Types[response.content_type]
  end

  # Returns the type for a File
  def type_for(file : File)
    type_for file.path
  end

  # Returns the type for a filename string
  def type_for(filename : String)
    for_extension File.extname(filename)
  end

  # Returns the type for a extension string
  def for_extension(ext : String)
    ext = ext.lchop(".")
    List.new.tap do |types|
      types.concat REGISTRY.select { |mime| mime.complete? && mime.preferred_extension == ext }
      types.concat REGISTRY.select { |mime| mime.complete? && mime.extensions.includes? ext }
    end
  end

  extend self
end

require "./types/*"
