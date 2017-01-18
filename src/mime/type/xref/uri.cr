require "json"

struct MIME::Type::XRef::URI < MIME::Type::XRef
  def url
    @value
  end
end
