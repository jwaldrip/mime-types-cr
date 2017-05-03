require "json"

# The definition of one MIME content-type.
#
# ## Usage
# ```
# require "mime/types"
# plaintext = MIME::Types["text/plain"]
# # returns [text/plain, text/plain]
# text = plaintext.first
# print text.media_type # => "text"
# print text.sub_type   # => "plain"
#
# puts text.extensions.join(" ") # => "asc txt c cc h hh cpp"
#
# puts text.encoding                         # => 8bit
# puts text.binary?                          # => false
# puts text.ascii?                           # => true
# puts text == "text/plain"                  # => true
# puts MIME::Type.simplified("x-appl/x-zip") # => "appl/zip"
# ```
struct MIME::Type
  private MEDIA_TYPE_RE = %r{(?<media_type>[-\w.+]+)/(?<sub_type>[-\w.+]*)}
  private I18N_RE = %r{[^[:alnum:]]}
  private BINARY_ENCODINGS = %w(base64 8bit)
  private ASCII_ENCODINGS = %w(7bit quoted-printable)
  private ENCODINGS = BINARY_ENCODINGS + ASCII_ENCODINGS

  include Comparable(MIME::Type)

  # Returns the whole MIME content-type string.
  #
  # The content type is a presentation value from the MIME type registry and
  # should not be used for comparison. The case of the content type is
  # preserved, and extension markers (*x-*) are kept.
  #
  #   text/plain        => text/plain
  #   x-chemical/x-pdb  => x-chemical/x-pdb
  #   audio/QCELP       => audio/QCELP
  getter content_type : String

  # The list of extensions which are known to be used for this MIME::Type.
  # Non-array values will be coerced into an array with #to_a. Array values
  # will be flattened, *nil* values removed, and made unique.
  getter extensions : Set(String)

  # The encoding (*7bit*, *8bit*, *quoted-printable*, or *base64*)
  # required to transport the data of this content type safely across a
  # network, which roughly corresponds to Content-Transfer-Encoding. A value of
  # *nil* or *:default* will reset the #encoding to the
  # #default_encoding for the MIME::Type. Raises ArgumentError if the encoding
  # provided is invalid.
  #
  # If the encoding is not provided on construction, this will be either
  # 'quoted-printable' (for text/* media types) and 'base64' for eveything
  # else.
  getter encoding : String

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

  def_hash @content_type

  # Return a `MatchData` object of the *content_type* against pattern of
  # media types.
  def self.match(content_type : String)
    MEDIA_TYPE_RE.match(content_type)
  end

  # MIME media types are case-insensitive, but are typically presented in a
  # case-preserving format in the type registry. This method converts
  # *content_type* to lowercase.
  #
  # In previous versions of mime-types, this would also remove any extension
  # prefix (*x-*). This is no longer default behaviour, but may be
  # provided by providing a truth value to *remove_x_prefix*.
  def self.simplified(content_type, remove_x = false)
    simplify_matchdata(match(content_type), remove_x: remove_x)
  end

  # Converts a provided *content_type* into a translation key suitable for
  # use with the I18n library.
  def self.i18n_key(content_type)
    simplify_matchdata(match(content_type), joiner: '.') { |e|
      e.gsub!(I18N_RE, "-")
    }
  end

  private def self.simplify_matchdata(match_data : Nil, remove_x = false, joiner = "/")
  end

  private def self.simplify_matchdata(match_data : Regex::MatchData, remove_x = false, joiner = "/")
    captures = [match_data[1], match_data[2]]
    captures.map do |e|
      e = e.downcase
      e = e.lchop("x-") if remove_x
      e
    end.join(joiner)
  end

  # Builds a `MIME::Type` object from the *content_type*, a MIME Content Type
  # value (e.g., "text/plain" or "applicaton/x-eruby"). The constructed object
  # is yielded to an optional block for additional configuration, such as
  # associating extensions and encoding information.
  #
  # * When provided a Hash or a `MIME::Type`, the `MIME::Type` will be
  #   constructed with #init_with.
  # * When provided an `Array`, the `MIME::Type` will be constructed using
  #   the first element as the content type and the remaining flattened
  #   elements as extensions.
  # * Otherwise, the *content_type* will be used as a string.
  #
  # Yields the newly constructed *self* object.
  def initialize(content_type : String,
                 extensions : Enumerable(String) = [] of String,
                 encoding : String | Nil = nil,
                 @signature = false,
                 @registered = false,
                 @obsolete = false,
                 @docs = nil,
                 @xrefs = XRefMap.new,
                 @friendly = {} of String => String)
    raise InvalidContentType.new(content_type) unless self.class.match(content_type)
    @content_type = content_type
    raise InvalidEncoding.new(encoding) unless ENCODINGS.includes?(encoding) || encoding.nil?
    @encoding = encoding || default_encoding
    @extensions = extensions.to_set
  end

  def inspect(io)
    to_s(io)
  end

  def to_s(io)
    io << content_type
  end

  # The preferred extension for this MIME type. If one is not set and there are
  # exceptions defined, the first extension will be used.
  #
  # When setting #preferred_extensions, if #extensions does not contain this
  # extension, this will be added to #xtensions.
  def preferred_extension
    extensions.first
  end

  def preferred_extension=(ext : String)
    ary = @extensions.to_a
    @extensions.clear
    @extensions.add ext
    ary.each { |ext| @extensions.add ext }
    ext
  end

  # Returns the media type of the simplified MIME::Type.
  #
  #   * text/plain        => text
  #   * x-chemical/x-pdb  => x-chemical
  #   * audio/QCELP       => audio
  def media_type
    self.class.match(simplified).try(&.["media_type"]).to_s
  end

  # Returns the media type of the unmodified MIME::Type.
  #
  #   * text/plain        => text
  #   * x-chemical/x-pdb  => x-chemical
  #   * audio/QCELP       => audio
  def raw_media_type
    self.class.match(@content_type).try(&.["media_type"]).to_s
  end

  # Returns the sub-type of the simplified MIME::Type.
  #
  #   * text/plain        => plain
  #   * x-chemical/x-pdb  => pdb
  #   * audio/QCELP       => qcelp
  def sub_type
    self.class.match(simplified).try(&.["sub_type"]).to_s
  end

  # Returns the media type of the unmodified MIME::Type.
  #
  #   * text/plain        => plain
  #   * x-chemical/x-pdb  => x-pdb
  #   * audio/QCELP       => QCELP
  def raw_sub_type
    self.class.match(@content_type).try(&.["sub_type"]).to_s
  end

  def complete?
    !extensions.empty?
  end

  # MIME types can be specified to be sent across a network in particular
  # formats. This method returns *false* when the MIME::Type encoding is
  # set to *base64*.
  def ascii?
    ASCII_ENCODINGS.includes?(encoding)
  end

  # MIME types can be specified to be sent across a network in particular
  # formats. This method returns *true* when the MIME::Type encoding is set
  # to *base64*.
  def binary?
    BINARY_ENCODINGS.includes?(encoding)
  end

  # Indicates whether the MIME type has been registered with IANA.
  getter? registered : Bool

  # Indicateswhether the MIME type is declared as a signature type.
  getter? signature : Bool

  # Returns *true* if the media type is obsolete.
  getter? obsolete

  # The decoded cross-reference URL list for this MIME::Type.
  def xref_urls
    xrefs.urls
  end

  # Returns the media type or types that should be used instead of this media
  # type, if it is obsolete. If there is no replacement media type, or it is
  # not obsolete, *nil* will be returned.
  def use_instead
    obsolete? ? @use_instead : nil
  end

  def friendly(lang : String = "en")
    @friendly[lang]
  end

  def set_friendly(name : String, lang : String = "en")
    @friendly[lang] = name
  end

  # Indicates that a MIME type is like another type. This differs from
  # *==* because *x-* prefixes are removed for this comparison.
  def like?(other)
    simplified(true) == other.simplified(true)
  end

  # Returns *true* if the *other* object is a MIME::Type and the content types
  # match.
  def eql?(other : Type)
    self == other
  end

  def eql?(other)
    false
  end

  # Returns *true* if the *other* object is a MIME::Type and the content types
  # match.
  def ==(other : Type)
    simplified == other.simplified
  end

  def ==(other : String)
    self == self.class.new(other)
  end

  def ==(other)
    self == other.to_s
  end

  # Compares the *other* MIME::Type against the exact content type or the
  # simplified type (the simplified type will be used if comparing against
  # something that can be treated as a String with #to_s). In comparisons, this
  # is done against the lowercase version of the MIME::Type.
  def <=>(other : Type)
    simplified <=> other.simplified
  end

  def <=>(other : Nil)
    -1
  end

  def <=>(other)
    simplified <=> other.to_s
  end

  # A simplified form of the MIME content-type string, suitable for
  # case-insensitive comparison, with any extension markers (<tt>x-</tt)
  # removed and converted to lowercase.
  #
  #   * text/plain        => text/plain
  #   * x-chemical/x-pdb  => x-chemical/x-pdb
  #   * audio/QCELP       => audio/qcelp
  def simplified(remove_x = false)
    MIME::Type.simplified(@content_type, remove_x).to_s
  end

  # Compares the *other* MIME::Type based on how reliable it is before doing a
  # normal <=> comparison. Used by MIME::Types#[] to sort types. The
  # comparisons involved are:
  #
  # 1. self.simplified <=> other.simplified (ensures that we
  #    don't try to compare different types)
  # 2. IANA-registered definitions < other definitions.
  # 3. Complete definitions < incomplete definitions.
  # 4. Current definitions < obsolete definitions.
  # 5. Obselete with use-instead names < obsolete without.
  # 6. Obsolete use-instead definitions are compared.
  #
  # While this method is public, its use is strongly discouraged by consumers
  # of mime-types. In mime-types 3, this method is likely to see substantial
  # revision and simplification to ensure current registered content types sort
  # before unregistered or obsolete content types.
  def priority_compare(other : Type)
    pc = self <=> other
    if pc == 0
      pc = if (reg = registered?) != other.registered?
             reg ? -1 : 1 # registered < unregistered
           elsif (comp = complete?) != other.complete?
             comp ? -1 : 1 # complete < incomplete
           elsif (obs = obsolete?) != other.obsolete?
             obs ? 1 : -1 # current < obsolete
           elsif obs && ((ui = use_instead) != (oui = other.use_instead))
             if ui.nil?
               1
             elsif oui.nil?
               -1
             else
               ui <=> oui
             end
           else
             0
           end
    end

    pc
  end

  def priority_compare(other : String)
    priority_compare(self.class.new(other))
  end

  private def default_encoding
    media_type == "text" ? "quoted-printable" : "base64"
  end
end

require "./type/*"
