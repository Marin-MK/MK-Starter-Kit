class Type < Serializable
  Cache = {}

  # @return [Symbol] the internal name of the type.
  attr_reader :intname
  # @return [Integer] the ID of the type.
  attr_reader :id
  # @return [String] the name of the type.
  attr_reader :name
  # @return [Array<Symbol>] the types the type is strong against.
  attr_reader :strong_against
  # @return [Array<Symbol>] the types the type is resistant to.
  attr_reader :resistant_to
  # @return [Array<Symbol>] the types the type is immune to.
  attr_reader :immune_to
  # @return [Symbol] the category moves of this type belong to.
  attr_reader :category

  # Creates a new Type object.
  def initialize(&block)
    validate block => Proc
    @id = 0
    @strong_against = []
    @resistant_to = []
    @immune_to = []
    instance_eval(&block)
    validate_type
    Cache[@intname] = self
    self.class.const_set(@intname, self)
  end

  # Ensures this type contains valid data.
  def validate_type
    validate \
        @intname => Symbol,
        @id => Integer,
        @category => Symbol
    validate_array \
        @strong_against => [Symbol, Integer],
        @resistant_to => [Symbol, Integer],
        @immune_to => [Symbol, Integer]
    raise "Cannot have an ID of 0 or lower for new Type object" if @id < 1
  end

  # Ensures all types contain valid data.
  def self.validate_all_types
    intnames = Cache.keys
    Cache.each_value do |type|
      type.strong_against.each do |k|
        if !intnames.include?(k)
          raise "Type #{k.inspect} could not be found, located in #strong_against in Type #{type.intname.inspect}"
        end
      end
      type.resistant_to.each do |k|
        if !intnames.include?(k)
          raise "Type #{k.inspect} could not be found, located in #resistant_to in Type #{type.intname.inspect}"
        end
      end
      type.immune_to.each do |k|
        if !intnames.include?(k)
          raise "Type #{k.inspect} could not be found, located in #immune_to in Type #{type.intname.inspect}"
        end
      end
    end
  end

  # @param type [Symbol, Integer] the type to look up.
  # @return [Type]
  def self.get(type)
    validate type => [Symbol, Integer, Type]
    return type if type.is_a?(Type)
    unless Type.exists?(type)
      raise "No type could be found for #{type.inspect}"
    end
    return Type.try_get(type)
  end

  # @param type [Symbol, Integer] the type to look up.
  # @return [Type, NilClass]
  def self.try_get(type)
    validate type => [Symbol, Integer, Type]
    return type if type.is_a?(Type)
    return Cache[type] if type.is_a?(Symbol)
    return Cache.values.find { |t| t.id == type }
  end

  # @param type [Symbol, Integer] the type to look up.
  # @return [Boolean] whether or not the type exists.
  def self.exists?(type)
    validate type => [Symbol, Integer, Type]
    return true if type.is_a?(Type)
    return Cache.has_key?(type) if type.is_a?(Symbol)
    return Cache.values.any? { |t| t.id == type }
  end

  # @return [Type] a randomly chosen type's internal name.
  def self.random
    return Cache.keys.sample
  end

  # @return [Integer] the total number of types.
  def self.count
    return Cache.size
  end

  # Unused
  def status?
    return @category == :status
  end

  def physical?
    return @category == :physical
  end

  def special?
    return @category == :special
  end

  def strong_against?(type)
    type = Type.get(type)
    return @strong_against.include?(type.intname)
  end

  def resistant_to?(type)
    type = Type.get(type)
    return @resistant_to.include?(type.intname)
  end

  def immune_to?(type)
    type = Type.get(type)
    return @immune_to.include?(type.intname)
  end
end

Type.new do
  @intname = :NORMAL
  @id = 1
  @name = "NORMAL"
  @category = :physical
  @immune_to = [:GHOST]
end

Type.new do
  @intname = :FIGHTING
  @id = 2
  @name = "FIGHTING"
  @category = :physical
  @strong_against = [:NORMAL, :ICE, :DARK, :ROCK, :STEEL]
  @resistant_to = [:BUG, :DARK, :ROCK]
end

Type.new do
  @intname = :FLYING
  @id = 3
  @name = "FLYING"
  @category = :physical
  @strong_against = [:BUG, :FIGHTING, :GRASS]
  @resistant_to = [:BUG, :FIGHTING, :GRASS]
  @immune_to = [:GROUND]
end

Type.new do
  @intname = :POISON
  @id = 4
  @name = "POISON"
  @category = :physical
  @strong_against = [:GRASS]
  @resistant_to = [:FIGHTING, :POISON, :BUG, :GRASS]
end

Type.new do
  @intname = :GROUND
  @id = 5
  @name = "GROUND"
  @category = :physical
  @strong_against = [:ELECTRIC, :FIRE, :POISON, :ROCK, :STEEL]
  @resistant_to = [:POISON, :ROCK]
  @immune_to = [:ELECTRIC]
end

Type.new do
  @intname = :ROCK
  @id = 6
  @name = "ROCK"
  @category = :physical
  @strong_against = [:BUG, :FIRE, :FLYING, :ICE]
  @resistant_to = [:FIRE, :FLYING, :NORMAL, :POISON]
end

Type.new do
  @intname = :BUG
  @id = 7
  @name = "BUG"
  @category = :physical
  @strong_against = [:DARK, :GRASS, :PSYCHIC]
  @resistant_to = [:FIGHTING, :GRASS, :GROUND]
end

Type.new do
  @intname = :GHOST
  @id = 8
  @name = "GHOST"
  @category = :physical
  @strong_against = [:GHOST, :PSYCHIC]
  @resistant_to = [:BUG, :POISON]
  @immune_to = [:NORMAL, :FIGHTING]
end

Type.new do
  @intname = :STEEL
  @id = 9
  @name = "STEEL"
  @category = :physical
  @strong_against = [:ICE, :ROCK]
  @resistant_to = [:BUG, :DARK, :DRAGON, :FLYING, :GHOST, :GRASS, :ICE, :NORMAL, :PSYCHIC, :ROCK, :STEEL]
  @immune_to = [:POISON]
end

Type.new do
  @intname = :QMARKS
  @id = 10
  @name = "???"
  @category = :status # unused
end

Type.new do
  @intname = :FIRE
  @id = 11
  @name = "FIRE"
  @category = :special
  @strong_against = [:BUG, :GRASS, :ICE, :STEEL]
  @resistant_to = [:BUG, :FIRE, :GRASS, :ICE, :STEEL]
end

Type.new do
  @intname = :WATER
  @id = 12
  @name = "WATER"
  @category = :special
  @strong_against = [:FIRE, :GROUND, :ROCK]
  @resistant_to = [:FIRE, :ICE, :STEEL, :WATER]
end

Type.new do
  @intname = :GRASS
  @id = 13
  @name = "GRASS"
  @category = :special
  @strong_against = [:GROUND, :ROCK, :WATER]
  @resistant_to = [:ELECTRIC, :GRASS, :GROUND, :WATER]
end

Type.new do
  @intname = :ELECTRIC
  @id = 14
  @name = "ELECTRIC"
  @category = :special
  @strong_against = [:FLYING, :WATER]
  @resistant_to = [:ELECTRIC, :FLYING, :STEEL]
end

Type.new do
  @intname = :PSYCHIC
  @id = 15
  @name = "PSYCHIC"
  @category = :special
  @strong_against = [:FIGHTING, :POISON]
  @resistant_to = [:FIGHTING, :PSYCHIC]
end

Type.new do
  @intname = :ICE
  @id = 16
  @name = "ICE"
  @category = :special
  @strong_against = [:DRAGON, :FLYING, :GRASS, :GROUND]
  @resistant_to = [:ICE]
end

Type.new do
  @intname = :DRAGON
  @id = 17
  @name = "DRAGON"
  @category = :special
  @strong_against = [:DRAGON]
  @resistant_to = [:ELECTRIC, :FIRE, :GRASS, :WATER]
end

Type.new do
  @intname = :DARK
  @id = 18
  @name = "DARK"
  @category = :special
  @strong_against = [:GHOST, :PSYCHIC]
  @resistant_to = [:DARK, :GHOST]
  @immune_to = [:PSYCHIC]
end
