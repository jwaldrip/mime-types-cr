class MIME::Types::Accept
  getter content_types : Array(String)
  @acceptable_types : Set(Type)

  def initialize(accept : String)
    @content_types = accept.split(",").flat_map(&.split(";").first.strip)
    @acceptable_types = Set(Type).new.tap do |mimes|
      content_types.each do |str|
        mimes.merge! Types[str]
      end
    end
  end

  def inspect(io)
    to_s(io)
  end

  def to_s(io)
    io << "#{self.class.name}{#{@content_types.join(", ")}}"
  end

  def extensions
    Set(String).new.tap do |set|
      @acceptable_types.map(&.extensions).each do |exts|
        set.merge! exts
      end
    end
  end

  forward_missing_to @acceptable_types
end
