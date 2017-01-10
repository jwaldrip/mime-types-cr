require "json"
require "./type"

# MIME::Types is a registry of MIME types. It is both a class (created with
# MIME::Types.new) and a default registry (loaded automatically or through
# interactions with MIME::Types.[] and MIME::Types.type_for).
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
  extend Enumerable(Type)
  private CACHE = [] of Type

  macro load(filename)
    {% json = run("../loader", filename) %}
    JSON.parse({{ json.stringify }}).each do |json|
      register Type.from_json json.to_json
    end
  end

  def self.register(mime : Type)
    CACHE << mime
  end

  def self.register(mimes : Array(Type))
    CACHE.concat mimes
  end

  def self.accepts(accepts : String)
    strings = accepts.split(",").flat_map(&.split(";").first)
    Set(Type).new.tap do |mimes|
      strings.each do |str|
        mimes.merge! self[str]
      end
      mimes.merge! CACHE if strings.includes? "*/*"
    end
  end

  def self.register(*args)
    CACHE << Type.new(*args)
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
  def self.[](content_type, complete = false, registered = false)
    CACHE.select { |mime| mime.content_type == content_type }.map(&.dup)
  end

  def self.for_extension(ext : String)
    CACHE.select { |mime| mime.preferred_extension == ext }.merge(
      CACHE.select { |mime| mime.extensions.inlude? ext }
    )
  end

  def self.registered
    CACHE.map(&.dup)
  end

  def self.count
    CACHE.count
  end

  def self.inspect(io)
    to_s io
  end

  def self.each
    MEDIA_TYPE_RE.each
  end

  def self.each
    CACHE.each do |item|
      yield item
    end
  end

  def self.to_s(io)
    io << "#<#{self.class}: #{count} variants, #{@extension_index.count} extensions>"
  end

  load "#{__DIR__}/../../data/mime-types.json"
end
