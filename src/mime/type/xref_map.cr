require "json"

class MIME::Type::XRefMap
  class XRefSet(T) < Array(T)
    def self.new
      new([] of String)
    end

    def self.new(pull : JSON::PullParser)
      pull.read_array do
        yield T.new(pull)
      end
    end

    def self.new(pull : JSON::PullParser)
      ary = new
      new(pull) do |element|
        ary << element
      end
      ary
    end

    def initialize(value : String)
      super(T.new value)
    end

    def initialize(values : Array(String))
      initialize(values.map { |value| T.new value })
    end

    def initialize(values : Array(T))
      initialize
      values.each { |value| self << value }
    end

    def <<(value : String)
      self << T.new(value)
    end

    def urls
      map(&.url)
    end
  end

  JSON.mapping({
    draft:      XRefSet(XRef::Draft) | Nil,
    person:     XRefSet(XRef::Person) | Nil,
    rfc_errata: {type: XRefSet(XRef::RfcErrata), nilable: true, key: "rfc-errata"},
    rfc:        XRefSet(XRef::Draft) | Nil,
    template:   XRefSet(XRef::Template) | Nil,
    uri:        XRefSet(XRef::URI) | Nil,
    notes:      XRefSet(XRef::Note) | Nil,
  }, true)

  def urls
    ([] of String).tap do |urls|
      if draft = @draft
        urls.concat draft.urls
      end
      if person = @person
        urls.concat person.urls
      end
      if rfc_errata = @rfc_errata
        urls.concat rfc_errata.urls
      end
      if rfc = @rfc
        urls.concat rfc.urls
      end
      if template = @template
        urls.concat template.urls
      end
      if uri = @uri
        urls.concat uri.urls
      end
      if notes = @notes
        urls.concat notes.urls
      end
    end
  end

  def draft=(value)
    self.draft = XRefSet(Draft).new(value)
  end

  def person=(value)
    self.person = XRefSet(Person).new(value)
  end

  def rfc_errata=(value)
    self.rfc_errata = XRefSet(RfcErrata).new(value)
  end

  def rfc=(value)
    self.rfc = XRefSet(Rfc).new(value)
  end

  def template=(value)
    self.template = XRefSet(Template).new(value)
  end

  def uri=(value)
    self.uri = XRefSet(Uri).new(value)
  end

  def notes=(value)
    self.notes = XRefSet(Note).new(value)
  end

  def initialize
  end
end

require "./xref/*"
