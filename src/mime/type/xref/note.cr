require "json"

class MIME::Type::XRef::Note < MIME::Type::XRef
  def url
    @value
  end
end
