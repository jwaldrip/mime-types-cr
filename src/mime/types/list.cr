require "../type"

module MIME::Types
  struct List
    include Enumerable(Type)
    include Iterable(Type)

    @index : Hash(Type, Nil)

    delegate each, to: to_a

    def initialize(initial_capacity = nil)
      @index = Hash(Type, Nil).new(initial_capacity: initial_capacity)
    end

    def initialize(items : Enumerable(Type))
      initialize(initial_capacity: items.size)
      items.each { |type| add type }
    end

    # Adds *type* to the list and returns `self`
    #
    # ```
    # s = MIME::Types::List{"text/html", "text/plain"}
    # s.includes? "text/plain" # => false
    # s << "application/json"
    # s.includes? "application/json" # => true
    # ```
    def add(type : Type)
      @index[type] = nil
      self
    end

    # Adds *type* to the list and returns `self`, delegating **args* to MIME::Type.new.
    #
    # ```
    # s = MIME::Types::List{"text/html", "text/plain"}
    # s.includes? "text/plain" # => false
    # s << 8
    # s.includes? 8 # => true
    # ```
    def add(*args)
      type = Type.new(*args)
      @index[type] = type
      self
    end

    # Alias for `add`
    def <<(object)
      add object
    end

    # Adds `#each` element of *types* to the list and returns `self`.
    #
    # ```
    # s = MIME::Types::List{"text/html", "text/plain"}
    # s.concat ["application/json"]
    # s.size # => 3
    # ```
    #
    # See also: `#|` to merge two lists and return a new one.
    def concat(elems : Enumerable(Type | String))
      elems.each { |elem| add elem }
      self
    end

    # Returns `true` if type exists in the list.
    #
    # ```
    # s = MIME::Types::List{"text/html", "text/plain"}
    # s.includes? "text/plain"       # => true
    # s.includes? "application/json" # => false
    # ```
    def includes?(type : Type)
      @index.has_key?(type)
    end

    def includes?(*args)
      includes? Type.new(*args)
    end

    # Removes the type from the list and returns `self`.
    #
    # ```
    # s = MIME::Types::List{"text/html", "text/plain"}
    # s.includes? "text/plain" # => true
    # s.remove MIME::Types["text/plain"]
    # s.includes? "text/plain" # => false
    # ```
    def remove(type : Type)
      @index.delete(type)
      self
    end

    # Removes *type* from the list and returns `self`, delegating **args* to MIME::Type.new.
    #
    # ```
    # s = MIME::Types::List{"text/html", "text/plain"}
    # s.includes? "text/plain" # => true
    # s.remove "text/plain"
    # s.includes? "text/plain" # => false
    # ```
    def remove(*args)
      type = Type.new(*args)
      @index.delete(type)
      self
    end

    # Returns `self` after removing from it those elements that are present in
    # the given enumerable.
    #
    # ```
    # MIME::Type::List{"text/plain", "text/html"}.remove ["text/plain"] # => MIME::Type::List{"text/html"}
    # ```
    def remove(other : Enumerable)
      other.each do |value|
        remove value
      end
      self
    end

    # Returns the number of types in the list.
    #
    # ```
    # s = MIME::Types::List{"text/html", "text/plain"}
    # s.size # => 2
    # ```
    def size
      @index.size
    end

    # Removes all types in the list, and returns `self`.
    #
    # ```
    # s = MIME::Types::List{"text/html", "text/plain"}
    # s.size # => 2
    # s.clear
    # s.size # => 0
    # ```
    def clear
      @index.clear
      self
    end

    # Returns `true` if the list is empty.
    #
    # ```
    # s = MIME::Types::List.new
    # s.empty? # => true
    # s << "text/plain"
    # s.empty? # => false
    # ```
    def empty?
      @index.empty?
    end

    # Yields each type in the list, and returns `self`.
    def each
      @index.each_key do |key|
        yield key
      end
    end

    # Returns an iterator for each type in the list.
    def each
      @index.each_key
    end

    # Intersection: returns a new list containing types common to both lists.
    #
    # ```
    # MIME::Type::List{"text/plain", "text/html"} & MIME::Type::List{"text/html", "application/json"} # => MIME::Type::List{"text/html"}
    # ```
    def &(other : List)
      List.new.tap do |list|
        each do |value|
          list.add value if other.includes?(value)
        end
      end
    end

    # Union: returns a new list containing all unique types from both lists.
    #
    # ```
    # MIME::Type::List{"text/plain", "text/html"} | MIME::Type::List{"text/html", "application/json"} # => MIME::Type::List{"text/html", "text/plain", "application/json"}
    # ```
    #
    # See also: `#merge` to add elements from a list to `self`.
    def |(other : List)
      List.new.tap do |list|
        each { |value| list.add value }
        other.each { |value| list.add value }
      end
    end

    # Difference: returns a new list containing types in this list that are not
    # present in the other.
    #
    # ```
    # MIME::Type::List{"text/html", "text/plain"} - MIME::Type::List{text/plain} # => MIME::Type::List{text/html}
    # ```
    def -(other : List)
      List.new.tap do |list|
        list.add value unless other.includes? value
      end
    end

    # Difference: returns a new list containing types in this list that are not
    # present in the other enumerable.
    #
    # ```
    # MIME::Type::List{"text/plain", "text/html"} - ["text/plain"] # => MIME::Type::List{text/html}
    # ```
    def -(other : Enumerable)
      dup.remove other
    end

    # Returns `true` if both lists have the same elements
    #
    # ```
    # MIME::Type::List{"text/plain", "text/html"} == MIME::Type::List{"text/plain", "text/html"} # => true
    # ```
    def ==(other : List)
      same?(other) || @index == other.@index
    end

    # Returns a new list with all of the same elements
    def dup
      List.new(self)
    end

    def clone
      self.class.new map(&.clone)
    end

    def to_a
      @index.keys
    end

    # lists all the extensions for all types in the list
    def extensions
      map(&.extensions).reduce(Set(String).new) do |iterator, exts|
        iterator | exts
      end
    end

    # Alias of `#to_s`
    def inspect(io)
      to_s(io)
    end

    def pretty_print(pp) : Nil
      pp.list("#{self.class.name}{", self, "}")
    end

    def hash
      @index.hash
    end

    # Returns `true` if the list and the given list have at least one element in
    # common.
    #
    # ```
    # MIME::Type::List{"text/plain", "text/html"}.intersects? MIME::Type::List{"application/xml", "application/json"} # => false
    # MIME::Type::List{"text/plain", "text/html"}.intersects? MIME::Type::List{"text/plain", "text/richtext"}         # => true
    # ```
    def intersects?(other : List)
      if size < other.size
        any? { |o| other.includes?(o) }
      else
        other.any? { |o| includes?(o) }
      end
    end

    # Writes a string representation of the list to *io*
    def to_s(io)
      io << "#{self.class.name}{"
      join ", ", io, &.inspect(io)
      io << "}"
    end

    # :nodoc:
    def object_id
      @index.object_id
    end

    # :nodoc:
    def same?(other : List)
      @index.same?(other.@index)
    end
  end
end
