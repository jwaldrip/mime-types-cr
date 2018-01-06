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

    def initialize(values : Enumerable(String))
      initialize(values.map { |value| T.new value })
    end

    def initialize(values : Enumerable(T))
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

  def initialize(draft : Array(String) | String | Nil = nil,
                 person : Array(String) | String | Nil = nil,
                 rfc_errata : Array(String) | String | Nil = nil,
                 rfc : Array(String) | String | Nil = nil,
                 template : Array(String) | String | Nil = nil,
                 uri : Array(String) | String | Nil = nil,
                 notes : Array(String) | String | Nil = nil)
    @draft = draft ? XRefSet(XRef::Draft).new(draft) : nil
    @person = person ? XRefSet(XRef::Person).new(person) : nil
    @rfc_errata = rfc_errata ? XRefSet(XRef::RfcErrata).new(rfc_errata) : nil
    @rfc = rfc ? XRefSet(XRef::Rfc).new(rfc) : nil
    @template = template ? XRefSet(XRef::Template).new(template) : nil
    @uri = uri ? XRefSet(XRef::URI).new(uri) : nil
    @notes = notes ? XRefSet(XRef::Note).new(notes) : nil
  end
end

require "./xref/*"
