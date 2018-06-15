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
