require "json"

struct MIME::Type::XRef::Rfc < MIME::Type::XRef
  def url
    "http://www.iana.org/go/#{@value}"
  end
end
