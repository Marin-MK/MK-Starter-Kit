class Nature
  Cache = {}

  attr_reader :intname
  attr_reader :id
  attr_reader :name
  attr_reader :buff
  attr_reader :debuff

  def initialize(&block)
    validate block => Proc
    @id = 0
    @name = ""
    instance_eval(&block)
    validate_nature
    Cache[@intname] = self
    self.class.const_set(@intname, self)
  end

  def validate_nature
    validate @intname => Symbol,
        @id => Integer,
        @name => String,
        @buff => [Symbol, NilClass],
        @debuff => [Symbol, NilClass]
    raise "Cannot have an ID of 0 or lower for new Nature object" if @id < 1
  end

  def self.get(nature)
    validate nature => [Symbol, Integer]
    unless Nature.exists?(nature)
      raise "No nature could be found for #{nature.inspect(50)}"
    end
    return Nature.try_get(nature)
  end

  def self.try_get(nature)
    validate nature => [Symbol, Integer]
    return Cache[nature] if nature.is_a?(Symbol)
    return Cache.values.find { |n| n.id == nature }
  end

  def self.exists?(nature)
    validate nature => [Symbol, Integer]
    return Cache.has_key?(nature) if nature.is_a?(Symbol)
    return Cache.values.any? { |n| n.id == nature }
  end

  def self.random
    return Cache.keys.sample
  end
end

# This would be loaded from a data file
Nature.new do
  @intname = :HARDY
  @id = 1
  @name = "Hardy"
end

Nature.new do
  @intname = :LONELY
  @id = 2
  @name = "Lonely"
  @buff = :attack
  @debuff = :defense
end

Nature.new do
  @intname = :BRAVE
  @id = 3
  @name = "Brave"
  @buff = :attack
  @debuff = :speed
end

Nature.new do
  @intname = :ADAMANT
  @id = 4
  @name = "Adamant"
  @buff = :attack
  @debuff = :spatk
end

Nature.new do
  @intname = :NAUGHTY
  @id = 5
  @name = "Naughty"
  @buff = :attack
  @debuff = :spdef
end

Nature.new do
  @intname = :BOLD
  @id = 6
  @name = "Bold"
  @buff = :defense
  @debuff = :attack
end

Nature.new do
  @intname = :DOCILE
  @id = 7
  @name = "Docile"
end

Nature.new do
  @intname = :RELAXED
  @id = 8
  @name = "Relaxed"
  @buff = :defense
  @debuff = :speed
end

Nature.new do
  @intname = :IMPISH
  @id = 9
  @name = "Impish"
  @buff = :defense
  @debuff = :spatk
end

Nature.new do
  @intname = :LAX
  @id = 10
  @name = "Lax"
  @buff = :defense
  @debuff = :spdef
end

Nature.new do
  @intname = :TIMID
  @id = 11
  @name = "Timid"
  @buff = :speed
  @debuff = :attack
end

Nature.new do
  @intname = :HASTY
  @id = 12
  @name = "Hasty"
  @buff = :speed
  @debuff = :defense
end

Nature.new do
  @intname = :SERIOUS
  @id = 13
  @name = "Serious"
end

Nature.new do
  @intname = :JOLLY
  @id = 14
  @name = "Jolly"
  @buff = :speed
  @debuff = :spatk
end

Nature.new do
  @intname = :NAIVE
  @id = 15
  @name = "Naive"
  @buff = :speed
  @debuff = :spdef
end

Nature.new do
  @intname = :MODEST
  @id = 16
  @name = "Modest"
  @buff = :spatk
  @debuff = :attack
end

Nature.new do
  @intname = :MILD
  @id = 17
  @name = "Mild"
  @buff = :spatk
  @debuff = :defense
end

Nature.new do
  @intname = :QUIET
  @id = 18
  @name = "Quiet"
  @buff = :spatk
  @debuff = :speed
end

Nature.new do
  @intname = :BASHFUL
  @id = 19
  @name = "Bashful"
end

Nature.new do
  @intname = :RASH
  @id = 20
  @name = "Rash"
  @buff = :spatk
  @debuff = :spdef
end

Nature.new do
  @intname = :CALM
  @id = 21
  @name = "Calm"
  @buff = :spdef
  @debuff = :attack
end

Nature.new do
  @intname = :GENTLE
  @id = 22
  @name = "Gentle"
  @buff = :spdef
  @debuff = :defense
end

Nature.new do
  @intname = :SASSY
  @id = 23
  @name = "Sassy"
  @buff = :spdef
  @debuff = :speed
end

Nature.new do
  @intname = :CAREFUL
  @id = 24
  @name = "Careful"
  @buff = :spdef
  @debuff = :spatk
end

Nature.new do
  @intname = :QUIRKY
  @id = 25
  @name = "Quirky"
end
