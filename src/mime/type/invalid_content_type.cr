# Reflects a MIME content-type specification that is not correctly
# formatted (it isn't +type+/+subtype+).
class MIME::Type::InvalidContentType < ArgumentError
  def initialize(content_type : String)
    super("Invalid Content-Type #{content_type.inspect}")
  end
end
