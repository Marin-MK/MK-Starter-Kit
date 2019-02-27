class Move
  Cache = {}

  # @return [Symbol] the internal name of the move.
  attr_reader :intname
  # @return [Integer] the ID of the move.
  attr_reader :id
  # @return [String] the name of the move.
  attr_reader :name
  # @return [Symbol] the type of the move.
  attr_reader :type
  # @return [Integer] the base power of the move.
  attr_reader :power
  # @return [Integer] the total PP of the move.
  attr_reader :totalpp
  # @return [Integer] the base accuracy of the move.
  attr_reader :accuracy
  # @return [Symbol] the category of the move.
  attr_reader :category
  # @return [Symbol] the target mode of the move.
  attr_reader :target_mode
  # @return [String] the description of the move.
  attr_reader :description

  # Creates a new Move object.
  def initialize(&block)
    validate block => Proc
    @id = 0
    @target_mode = :opponent
    @description = ""
    instance_eval(&block)
    validate_move
    Cache[@intname] = self
    self.class.const_set(@intname, self)
  end

  # Ensures this move contains valid data.
  def validate_move
    validate @intname => Symbol,
        @id => Integer,
        @name => String,
        @type => Symbol,
        @power => Integer,
        @category => Symbol,
        @target_mode => Symbol,
        @description => String
    raise "Type #{@type.inspect(16)} doesn't exist for new Move object" unless Type.exists?(@type)
    unless [:physical, :special, :status].include?(@category)
      raise "Category #{@category.inspect(16)} must be one of :physical, :special or :status for new Move object"
    end
    raise "Cannot have an ID of 0 or lower for new Move object" if @id < 1
  end

  # @param move [Symbol, Integer] the move to look up.
  # @return [Move]
  def self.get(move)
    validate move => [Symbol, Integer]
    unless Move.exists?(move)
      raise "No move could be found for #{move.inspect(50)}"
    end
    return Move.try_get(move)
  end

  # @param move [Symbol, Integer] the move to look up.
  # @return [Move, NilClass]
  def self.try_get(move)
    validate move => [Symbol, Integer]
    return Cache[move] if move.is_a?(Symbol)
    return Cache.values.find { |m| m.id == move }
  end

  # @param move [Symbol, Integer] the move to look up.
  # @return [Boolean] whether or not the move exists.
  def self.exists?(move)
    validate move => [Symbol, Integer]
    return Cache.has_key?(move) if move.is_a?(Symbol)
    return Cache.values.any? { |m| m.id == move }
  end

  # @return [Move] a randomly chosen move's internal name.
  def self.random
    return Cache.keys.sample
  end
end

# Target modes:
# :opponent
# :single (may also affect partner if chosen)
# :self
# :ally
# :all_allies
# :all_opponents

Move.new do
  @intname = :POUND
  @id = 1
  @name = "Pound"
  @type = :NORMAL
  @power = 40
  @totalpp = 35
  @accuracy = 100
  @category = :physical
  @description = "A physical attack delivered with a long tail or a foreleg, etc."
end

Move.new do
  @intname = :TACKLE
  @id = 33
  @name = "Tackle"
  @type = :NORMAL
  @power = 35
  @totalpp = 35
  @accuracy = 95
  @category = :physical
  @description = "A physical attack in which the user charges, full body, into the foe."
end

Move.new do
  @intname = :GROWL
  @id = 45
  @name = "Growl"
  @type = :NORMAL
  @power = 0
  @totalpp = 40
  @accuracy = 100
  @category = :status
  @target_mode = :all_opponents
  @description = "The user growls in a cute way, making the foe lower its Attack stat."
end

Move.new do
  @intname = :LEECHSEED
  @id = 73
  @name = "Leech Seed"
  @type = :GRASS
  @power = 0
  @totalpp = 10
  @accuracy = 100
  @category = :status
  @description = "A seed is planted on the foe to steal some HP for the user on every turn."
end

Move.new do
  @intname = :VINEWHIP
  @id = 22
  @name = "Vine Whip"
  @type = :GRASS
  @power = 35
  @totalpp = 10
  @accuracy = 100
  @category = :physical
  @description = "The foe is struck with slender, whiplike vines."
end

Move.new do
  @intname = :POISONPOWDER
  @id = 77
  @name = "Poison Powder"
  @type = :POISON
  @power = 0
  @totalpp = 35
  @accuracy = 75
  @category = :status
  @description = "A cloud of toxic dust is scattered. It may poison the foe."
end

Move.new do
  @intname = :SLEEPPOWDER
  @id = 79
  @name = "Sleep Powder"
  @type = :GRASS
  @power = 0
  @totalpp = 15
  @accuracy = 75
  @category = :status
  @description = "A sleep-inducing dust is scattered in high volume around a foe."
end

Move.new do
  @intname = :RAZORLEAF
  @id = 75
  @name = "Razor Leaf"
  @type = :GRASS
  @power = 55
  @totalpp = 25
  @accuracy = 95
  @category = :physical
  @target_mode = :all_opponents
  @description = "The foe is hit with a cutting leaf. It has a high critical-hit ratio."
end

Move.new do
  @intname = :SWEETSCENT
  @id = 230
  @name = "Sweet Scent"
  @type = :NORMAL
  @power = 0
  @totalpp = 20
  @accuracy = 100
  @category = :status
  @target_mode = :all_opponents
  @description = "Allures the foe to reduce evasiveness. It also attracts wild Pokémon."
end

Move.new do
  @intname = :GROWTH
  @id = 74
  @name = "Growth"
  @type = :NORMAL
  @power = 0
  @totalpp = 40
  @accuracy = 0
  @category = :status
  @target_mode = :self
  @description = "The user's body is forced to grow, raising the Sp. Atk stat."
end

Move.new do
  @intname = :SYNTHESIS
  @id = 235
  @name = "Synthesis"
  @type = :GRASS
  @power = 0
  @totalpp = 5
  @accuracy = 0
  @category = :status
  @target_mode = :self
  @description = "Restores the user's HP. The amount of HP regained varies with the weather."
end

Move.new do
  @intname = :SOLARBEAM
  @id = 76
  @name = "SolarBeam"
  @type = :GRASS
  @power = 120
  @totalpp = 10
  @accuracy = 100
  @category = :special
  @description = "A 2-turn move that blasts the foe with absorbed energy in the 2nd turn."
end
