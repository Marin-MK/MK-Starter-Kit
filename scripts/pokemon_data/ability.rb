class Ability
  Cache = {}

  # @return [String] the internal name of the ability.
  attr_reader :intname
  # @return [Integer] the ID of the ability.
  attr_reader :id

  # Creates a new Ability object.
  def initialize(&block)
    validate block => Proc
    @id = 0
    @description = ""
    instance_eval(&block)
    validate_ability
    Cache[@intname] = self
    self.class.const_set(@intname, self)
  end

  # Ensures this ability contains valid data.
  def validate_ability
    validate @intname => Symbol,
        @id => Integer,
        @name => String,
        @description => String
    raise "Cannot have an ID of 0 or lower for new Ability object" if @id < 1
  end

  # @param ability [Symbol, Integer] the ability to look up.
  # @return [Ability]
  def self.get(ability)
    validate ability => [Symbol, Integer]
    unless Ability.exists?(ability)
      raise "No ability could be found for argument #{ability.inspect(50)}"
    end
    return Ability.try_get(ability)
  end

  # @param ability [Symbol, Integer] the ability to look up.
  # @return [Ability, NilClass]
  def self.try_get(ability)
    validate ability => [Symbol, Integer]
    return Cache[ability] if ability.is_a?(Symbol)
    return Cache.values.find { |a| a.id == ability }
  end

  # @param ability [Symbol, Integer] the ability to look up.
  # @return [Boolean] whether or not the ability exists.
  def self.exists?(ability)
    return Cache.has_key?(ability) if ability.is_a?(Symbol)
    return Cache.values.any? { |a| a.id == ability }
  end

  # @return [Ability] a randomly chosen ability's internal name.
  def self.random
    return Cache.keys.sample
  end
end

# This would be loaded from a data file
Ability.new do
  @id = 1
  @intname = :STENCH
  @name = "Stench"
  @description = "Helps repel wild Pokémon."
end

Ability.new do
  @intname = :OVERGROW
  @id = 65
  @name = "Overgrow"
  @description = "Ups Grass moves in a pinch."
end
