# Reflects an unsupported MIME encoding.
class MIME::Type::InvalidEncoding < ArgumentError
  def initialize(encoding : String)
    super("Invalid Encoding #{encoding.inspect}")
  end
end
