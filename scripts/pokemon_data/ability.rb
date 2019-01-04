class Ability
  Cache = {}

  attr_reader :intname
  attr_reader :id

  def initialize(&block)
    validate block => Proc
    @id = 0
    @name = ""
    @description = ""
    instance_eval(&block)
    validate_ability
    Cache[@intname] = self
    self.class.const_set(@intname, self)
  end

  def validate_ability
    validate @intname => Symbol,
        @id => Integer,
        @name => String,
        @description => String
    raise "Cannot have an ID of 0 or lower for new Ability object" if @id < 1
  end

  def self.get(ability)
    validate ability => [Symbol, Integer]
    unless Ability.exists?(ability)
      raise "No ability could be found for argument #{ability.inspect(50)}"
    end
    return Ability.try_get(ability)
  end

  def self.try_get(ability)
    validate ability => [Symbol, Integer]
    return Cache[ability] if ability.is_a?(Symbol)
    return Cache.values.find { |a| a.id == ability }
  end

  def self.exists?(ability)
    return Cache.has_key?(ability) if ability.is_a?(Symbol)
    return Cache.values.any? { |a| a.id == ability }
  end

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
