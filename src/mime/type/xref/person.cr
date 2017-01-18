require "json"

struct MIME::Type::XRef::Person < MIME::Type::XRef
  def url
    "http://www.iana.org/assignments/media-types/media-types.xhtml##{@value}"
  end
end
