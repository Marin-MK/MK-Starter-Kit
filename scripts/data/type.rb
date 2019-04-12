class Type
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
    validate @intname => Symbol,
        @id => Integer
    validate_array @strong_against => [Symbol, Integer],
        @resistant_to => [Symbol, Integer],
        @immune_to => [Symbol, Integer]
    raise "Cannot have an ID of 0 or lower for new Type object" if @id < 1
  end

  # Ensures all types contain valid data.
  def self.validate_all_types
    intnames = Cache.keys
    Cache.values.each do |type|
      type.strong_against.each do |k|
        if !intnames.include?(k)
          raise "Type #{k.inspect(16)} could not be found, located in #strong_against in Type #{type.intname.inspect(16)}"
        end
      end
      type.resistant_to.each do |k|
        if !intnames.include?(k)
          raise "Type #{k.inspect(16)} could not be found, located in #resistant_to in Type #{type.intname.inspect(16)}"
        end
      end
      type.immune_to.each do |k|
        if !intnames.include?(k)
          raise "Type #{k.inspect(16)} could not be found, located in #immune_to in Type #{type.intname.inspect(16)}"
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
      raise "No type could be found for #{type.inspect(50)}"
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
end

Type.new do
  @intname = :NORMAL
  @id = 1
  @name = "Normal"
  @immune_to = [:GHOST]
end

Type.new do
  @intname = :FIGHTING
  @id = 2
  @name = "Fighting"
  @strong_against = [:NORMAL, :ICE, :DARK, :ROCK, :STEEL]
  @resistant_to = [:BUG, :DARK, :ROCK]
end

Type.new do
  @intname = :FLYING
  @id = 3
  @name = "Flying"
  @strong_against = [:BUG, :FIGHTING, :GRASS]
  @resistant_to = [:BUG, :FIGHTING, :GRASS]
  @immune_to = [:GROUND]
end

Type.new do
  @intname = :POISON
  @id = 4
  @name = "Poison"
  @strong_against = [:GRASS]
  @resistant_to = [:FIGHTING, :POISON, :BUG, :GRASS]
end

Type.new do
  @intname = :GROUND
  @id = 5
  @name = "Ground"
  @strong_against = [:ELECTRIC, :FIRE, :POISON, :ROCK, :STEEL]
  @resistant_to = [:POISON, :ROCK]
  @immune_to = [:ELECTRIC]
end

Type.new do
  @intname = :ROCK
  @id = 6
  @name = "Rock"
  @strong_against = [:BUG, :FIRE, :FLYING, :ICE]
  @resistant_to = [:FIRE, :FLYING, :NORMAL, :POISON]
end

Type.new do
  @intname = :BUG
  @id = 7
  @name = "Bug"
  @strong_against = [:DARK, :GRASS, :PSYCHIC]
  @resistant_to = [:FIGHTING, :GRASS, :GROUND]
end

Type.new do
  @intname = :GHOST
  @id = 8
  @name = "Ghost"
  @strong_against = [:GHOST, :PSYCHIC]
  @resistant_to = [:BUG, :POISON]
  @immune_to = [:NORMAL, :FIGHTING]
end

Type.new do
  @intname = :STEEL
  @id = 9
  @name = "Steel"
  @strong_against = [:ICE, :ROCK]
  @resistant_to = [:BUG, :DARK, :DRAGON, :FLYING, :GHOST, :GRASS, :ICE, :NORMAL, :PSYCHIC, :ROCK, :STEEL]
  @immune_to = [:POISON]
end

Type.new do
  @intname = :QMARKS
  @id = 10
  @name = "???"
end

Type.new do
  @intname = :FIRE
  @id = 11
  @name = "Fire"
  @strong_against = [:BUG, :GRASS, :ICE, :STEEL]
  @resistant_to = [:BUG, :FIRE, :GRASS, :ICE, :STEEL]
end

Type.new do
  @intname = :WATER
  @id = 12
  @name = "Water"
  @strong_against = [:FIRE, :GROUND, :ROCK]
  @resistant_to = [:FIRE, :ICE, :STEEL, :WATER]
end

Type.new do
  @intname = :GRASS
  @id = 13
  @name = "Grass"
  @strong_against = [:GROUND, :ROCK, :WATER]
  @resistant_to = [:ELECTRIC, :GRASS, :GROUND, :WATER]
end

Type.new do
  @intname = :ELECTRIC
  @id = 14
  @name = "Electric"
  @strong_against = [:FLYING, :WATER]
  @resistant_to = [:ELECTRIC, :FLYING, :STEEL]
end

Type.new do
  @intname = :PSYCHIC
  @id = 15
  @name = "Psychic"
  @strong_against = [:FIGHTING, :POISON]
  @resistant_to = [:FIGHTING, :PSYCHIC]
end

Type.new do
  @intname = :ICE
  @id = 16
  @name = "Ice"
  @strong_against = [:DRAGON, :FLYING, :GRASS, :GROUND]
  @resistant_to = [:ICE]
end

Type.new do
  @intname = :DRAGON
  @id = 17
  @name = "Dragon"
  @strong_against = [:DRAGON]
  @resistant_to = [:ELECTRIC, :FIRE, :GRASS, :WATER]
end

Type.new do
  @intname = :DARK
  @id = 18
  @name = "Dark"
  @strong_against = [:GHOST, :PSYCHIC]
  @resistant_to = [:DARK, :GHOST]
  @immune_to = [:PSYCHIC]
end
