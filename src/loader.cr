require "json"
require "./mime/type"

struct MIME::Type
  JSON.mapping({
    content_type: {type: String, key: "content-type", setter: false},
    encoding:     {type: String, setter: false},
    extensions:   {type: Set(String), default: Set(String).new, setter: false},
    xrefs:        {type: XRefMap, default: XRefMap.new, setter: false},
    friendly:     {type: Hash(String, String), default: {} of String => String, getter: false, setter: false},
    registered:   {type: Bool, setter: false},
    obsolete:     {type: Bool, default: false, setter: false},
    signature:    {type: Bool, default: false, setter: false},
    docs:         {type: String, nilable: true, setter: false},
    use_instead:  {type: String, getter: false, nilable: true, key: "use-instead", setter: false},
  }, true)

  def to_code
    "MIME::Type.new(#{@content_type.inspect}, #{@extensions.to_a.inspect} of String, encoding: #{@encoding.inspect}, signature: #{@signature.inspect}, registered: #{@registered.inspect}, obsolete: #{@obsolete.inspect}, docs: #{@docs.inspect}, xrefs: #{@xrefs.to_code}, friendly: #{@friendly.inspect} of String => String, use_instead: #{@use_instead.inspect})"
  end
end

class MIME::Type::XRefMap
  JSON.mapping({
    draft:      XRefSet(XRef::Draft) | Nil,
    person:     XRefSet(XRef::Person) | Nil,
    rfc_errata: {type: XRefSet(XRef::RfcErrata), nilable: true, key: "rfc-errata"},
    rfc:        XRefSet(XRef::Rfc) | Nil,
    template:   XRefSet(XRef::Template) | Nil,
    uri:        XRefSet(XRef::URI) | Nil,
    notes:      XRefSet(XRef::Note) | Nil,
  }, true)

  def to_code
    "MIME::Type::XRefMap.new(draft: #{@draft.inspect}, person: #{@person.inspect}, rfc_errata: #{@rfc_errata.inspect}, rfc: #{@rfc.inspect}, template: #{@template.inspect}, uri: #{@uri.inspect}, notes: #{notes.inspect})"
  end
end

Array(MIME::Type).from_json(File.read(ARGV[0])).each do |mime_type|
  puts "register #{mime_type.to_code}"
end
