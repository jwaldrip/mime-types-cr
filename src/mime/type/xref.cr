require "json"

abstract class MIME::Type::XRef
  abstract def url

  def initialize(@value : String)
  end

  def initialize(pull : JSON::PullParser)
    @value = pull.read_string
  end
end

require "./xref/*"
