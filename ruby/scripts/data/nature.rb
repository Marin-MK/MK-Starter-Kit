class Nature
  Cache = {}

  # @return [String] the internal name of the nature.
  attr_reader :intname
  # @return [Integer] the ID of the nature.
  attr_reader :id
  # @return [String] the name of the nature.
  attr_reader :name
  # @return [Symbol, NilClass] the stat this nature increases by x1.1.
  attr_reader :buff
  # @return [Symbol, NilClass] the stat this nature decreases by x0.9.
  attr_reader :debuff

  # Creates a new Nature object.
  def initialize(&block)
    validate block => Proc
    @id = 0
    @name = ""
    instance_eval(&block)
    validate_nature
    Cache[@intname] = self
    self.class.const_set(@intname, self)
  end

  # Ensures this nature contains valid data.
  def validate_nature
    validate @intname => Symbol,
        @id => Integer,
        @name => String,
        @buff => [Symbol, NilClass],
        @debuff => [Symbol, NilClass]
    raise "Cannot have an ID of 0 or lower for new Nature object" if @id < 1
  end

  # @param nature [Symbol, Integer] the nature to look up.
  # @return [Nature]
  def self.get(nature)
    validate nature => [Symbol, Integer, Nature]
    return nature if nature.is_a?(Nature)
    unless Nature.exists?(nature)
      raise "No nature could be found for #{nature.inspect}"
    end
    return Nature.try_get(nature)
  end

  # @param nature [Symbol, Integer] the nature to look up.
  # @return [Nature, NilClass]
  def self.try_get(nature)
    validate nature => [Symbol, Integer, Nature]
    return nature if nature.is_a?(Nature)
    return Cache[nature] if nature.is_a?(Symbol)
    return Cache.values.find { |n| n.id == nature }
  end

  # @param nature [Symbol, Integer] the nature to look up.
  # @return [Boolean] whether or not the nature exists.
  def self.exists?(nature)
    validate nature => [Symbol, Integer, Nature]
    return true if nature.is_a?(Nature)
    return Cache.has_key?(nature) if nature.is_a?(Symbol)
    return Cache.values.any? { |n| n.id == nature }
  end

  # @return [Nature] a randomly chosen nature's internal name.
  def self.random
    return Cache.keys.sample
  end

  # @return [Integer] the total number of natures.
  def self.count
    return Cache.size
  end
end

# This would be loaded from a data file
Nature.new do
  @intname = :HARDY
  @id = 1
  @name = "HARDY"
end

Nature.new do
  @intname = :LONELY
  @id = 2
  @name = "LONELY"
  @buff = :attack
  @debuff = :defense
end

Nature.new do
  @intname = :BRAVE
  @id = 3
  @name = "BRAVE"
  @buff = :attack
  @debuff = :speed
end

Nature.new do
  @intname = :ADAMANT
  @id = 4
  @name = "ADAMANT"
  @buff = :attack
  @debuff = :spatk
end

Nature.new do
  @intname = :NAUGHTY
  @id = 5
  @name = "NAUGHTY"
  @buff = :attack
  @debuff = :spdef
end

Nature.new do
  @intname = :BOLD
  @id = 6
  @name = "BOLD"
  @buff = :defense
  @debuff = :attack
end

Nature.new do
  @intname = :DOCILE
  @id = 7
  @name = "DOCILE"
end

Nature.new do
  @intname = :RELAXED
  @id = 8
  @name = "RELAXED"
  @buff = :defense
  @debuff = :speed
end

Nature.new do
  @intname = :IMPISH
  @id = 9
  @name = "IMPISH"
  @buff = :defense
  @debuff = :spatk
end

Nature.new do
  @intname = :LAX
  @id = 10
  @name = "LAX"
  @buff = :defense
  @debuff = :spdef
end

Nature.new do
  @intname = :TIMID
  @id = 11
  @name = "TIMID"
  @buff = :speed
  @debuff = :attack
end

Nature.new do
  @intname = :HASTY
  @id = 12
  @name = "HASTY"
  @buff = :speed
  @debuff = :defense
end

Nature.new do
  @intname = :SERIOUS
  @id = 13
  @name = "SERIOUS"
end

Nature.new do
  @intname = :JOLLY
  @id = 14
  @name = "JOLLY"
  @buff = :speed
  @debuff = :spatk
end

Nature.new do
  @intname = :NAIVE
  @id = 15
  @name = "NAIVE"
  @buff = :speed
  @debuff = :spdef
end

Nature.new do
  @intname = :MODEST
  @id = 16
  @name = "MODEST"
  @buff = :spatk
  @debuff = :attack
end

Nature.new do
  @intname = :MILD
  @id = 17
  @name = "MILD"
  @buff = :spatk
  @debuff = :defense
end

Nature.new do
  @intname = :QUIET
  @id = 18
  @name = "QUIET"
  @buff = :spatk
  @debuff = :speed
end

Nature.new do
  @intname = :BASHFUL
  @id = 19
  @name = "BASHFUL"
end

Nature.new do
  @intname = :RASH
  @id = 20
  @name = "RASH"
  @buff = :spatk
  @debuff = :spdef
end

Nature.new do
  @intname = :CALM
  @id = 21
  @name = "CALM"
  @buff = :spdef
  @debuff = :attack
end

Nature.new do
  @intname = :GENTLE
  @id = 22
  @name = "GENTLE"
  @buff = :spdef
  @debuff = :defense
end

Nature.new do
  @intname = :SASSY
  @id = 23
  @name = "SASSY"
  @buff = :spdef
  @debuff = :speed
end

Nature.new do
  @intname = :CAREFUL
  @id = 24
  @name = "CAREFUL"
  @buff = :spdef
  @debuff = :spatk
end

Nature.new do
  @intname = :QUIRKY
  @id = 25
  @name = "QUIRKY"
end
