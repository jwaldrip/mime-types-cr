require "json"

struct MIME::Type::XRef::Template < MIME::Type::XRef
  def url
    "http://www.iana.org/assignments/media-types/#{@value}"
  end
end
