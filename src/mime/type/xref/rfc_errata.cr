require "json"

struct MIME::Type::XRef::RfcErrata < MIME::Type::XRef
  def url
    "http://www.rfc-editor.org/errata_search.php?eid=#{@value}"
  end
end
