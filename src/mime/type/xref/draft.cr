require "json"

class MIME::Type::XRef::Draft < MIME::Type::XRef
  def url
    "http://www.iana.org/go/#{@value.sub(/\ARFC/, "draft")}"
  end
end
