require "json"

abstract struct MIME::Type::XRef
  abstract def url

  def initialize(@value : String)
  end

  def initialize(pull : JSON::PullParser)
    @value = pull.read_string
  end

  def inspect(io)
    to_s io
  end

  def to_s(io)
    io << @value.inspect
  end
end

require "./xref/*"
