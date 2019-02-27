Stats = Struct.new(:hp, :attack, :defense, :spatk, :spdef, :speed)

class Stats
  alias atk attack
  alias atk= attack=
  alias def defense
  alias def= defense=
  alias defence defense
  alias defence= defense=
  alias specialattack spatk
  alias specialattack= spatk=
  alias specialdefense spdef
  alias specialdefense= spdef=
  alias specialdefence spdef
  alias specialdefence= spdef=
  alias spd speed
  alias spd= speed=
end

class Species
  Cache = {}

  Moveset = Struct.new(:level, :tms, :tutor, :evolution, :egg)

  # @return [Symbol] the internal name of the species.
  attr_reader :intname
  # @return [Integer] the ID of the species.
  attr_reader :id
  # @return [String] the name of the species.
  attr_reader :name
  # @return [Symbol] type 1 of the species.
  attr_reader :type1
  # @return [Symbol, NilClass] type 2 of the species
  attr_reader :type2
  # @return [Stats] the base statistics of the species.
  attr_reader :stats
  # @return [Array<Symbol>] the possible abilities of the species.
  attr_reader :abilities
  # @return [Symbol, NilClass] the hidden ability of the species.
  attr_reader :hidden_ability
  # @return [Stats] the EV Yield of the species.
  attr_reader :ev_yield
  # @return [Array<Symbol>] the egg groups of the species.
  attr_reader :egg_groups
  # @return [Float] the height of the species in kg.
  attr_reader :height
  # @return [Float] the weight of the species in m.
  attr_reader :weight
  # @return [Integer] the Base EXP of the species.
  attr_reader :base_exp
  # @return [Symbol] the leveling rate of the species.
  attr_reader :leveling_rate
  # @return [Symbol] the gender ratio of the species.
  attr_reader :gender_ratio
  # @return [Integer] the catch rate of the species.
  attr_reader :catch_rate
  # @return [Integer] the minimum number of steps it takes to hatch an egg of the species.
  attr_reader :hatch_time
  # @return [Symbol] the Pokedex color of the species.
  attr_reader :pokedex_color
  # @return [String] the Pokedex entry of the species.
  attr_reader :pokedex_entry
  # @return [Integer] the initial friendship of pokemon of this species.
  attr_reader :friendship
  # @return [Moveset] the full moveset of the species.
  attr_reader :moveset
  # @return [Array<Hash>] all possible evolutions of the species.
  attr_reader :evolutions

  # Creates a new Species object.
  def initialize(&block)
    validate block => Proc
    @id = 0
    @stats = Stats.new
    @stats.keys.each { |key| @stats.set(key, 0) }
    @ev_yield = Stats.new
    @ev_yield.keys.each { |key| @ev_yield.set(key, 0) }
    @moveset = Moveset.new
    @moveset.level = {}
    @moveset.tms = []
    @moveset.tutor = []
    @moveset.evolution = []
    @moveset.egg = []
    instance_eval(&block)
    validate_species
    Cache[@intname] = self
    self.class.const_set(@intname, self)
  end

  # @return [Integer] the Base Stat Total of the species' base stats.
  def bst
    return @stats.hp + @stats.attack + @stats.defense + @stats.spatk + @stats.spdef + @stats.speed
  end

  # Ensures this species contains valid data.
  def validate_species
    validate @intname => Symbol,
        @id => Integer,
        @name => String,
        @type1 => Symbol,
        @type2 => [Symbol, NilClass],
        @stats => Stats,
        @abilities => Array,
        @hidden_ability => [Symbol, NilClass],
        @ev_yield => Stats,
        @egg_groups => Array,
        @height => Numeric,
        @weight => Numeric,
        @base_exp => Numeric,
        @leveling_rate => Symbol,
        @gender_ratio => Symbol,
        @catch_rate => Integer,
        @hatch_time => Range,
        @pokedex_color => Symbol,
        @pokedex_entry => String,
        @friendship => Integer,
        @moveset => Moveset,
        @evolutions => Array
    validate_array @abilities => Symbol,
        @egg_groups => Symbol,
        @evolutions => Hash
    raise "Cannot have an ID of 0 or lower for new Species object" if @id < 1
  end

  # @param species [Symbol, Integer] the species to look up.
  # @return [Species]
  def self.get(species)
    validate species => [Symbol, Integer]
    unless Species.exists?(species)
      raise "No species could be found for argument #{species.inspect(50)}"
    end
    return Species.try_get(species)
  end

  # @param species [Symbol, Integer] the species to look up.
  # @return [Species, NilClass]
  def self.try_get(species)
    validate species => [Symbol, Integer]
    return Cache[species] if species.is_a?(Symbol)
    return Cache.values.find { |s| s.id == species }
  end

  # @param species [Symbol, Integer] the species to look up.
  # @return [Boolean] whether or not the species exists.
  def self.exists?(species)
    validate species => [Symbol, Integer]
    return Cache.has_key?(species) if species.is_a?(Symbol)
    return Cache.values.any? { |s| s.id == species }
  end

  # @return [Species] a randomly chosen species' internal name.
  def self.random
    return Cache.keys.sample
  end

  def self.count
    return Cache.size
  end
end

# This would be loaded from a data file
Species.new do
  @intname = :BULBASAUR
  @id = 1
  @name = "Bulbasaur"
  @type1 = :GRASS
  @type2 = :POISON
  @stats.hp = 45
  @stats.atk = 49
  @stats.def = 49
  @stats.spatk = 65
  @stats.spdef = 65
  @stats.spd = 45
  @abilities = [:OVERGROW]
  @hidden_ability = :CHLOROPHYLL
  @ev_yield.spatk = 1
  @egg_groups = [:MONSTER, :GRASS]
  @height = 0.7
  @weight = 6.9
  @base_exp = 64
  @leveling_rate = :MEDIUMSLOW
  @gender_ratio = :FEMALEONEEIGHTH
  @catch_rate = 45
  @hatch_time = 5140..5396
  @pokedex_color = :GREEN
  @pokedex_entry = "There is a plant seed on its back right from the day this Pokémon is born. The seed slowly grows larger."
  @friendship = 70
  @moveset.level = {
    1 => :TACKLE,
    4 => :GROWL,
    7 => :LEECHSEED,
    10 => :VINEWHIP,
    15 => [:POISONPOWDER, :SLEEPPOWDER],
    20 => :RAZORLEAF,
    25 => :SWEETSCENT,
    32 => :GROWTH,
    39 => :SYNTHESIS,
    46 => :SOLARBEAM
  }
  @moveset.tms = [:TOXIC, :BULLETSEED, :HIDDENPOWER, :SUNNYDAY, :PROTECT, :GIGADRAIN, :FRUSTRSTION, :SOLARBEAM, :RETURN, :DOUBLETEAM, :SLUDGEBOMB, :FACADE, :SECRETPOWER, :REST, :ATTRACT, :CUT, :STRENGTH, :FLASH, :ROCKSMASH],
  @moveset.egg = [:CHARM, :CURSE, :GRASSWHISTLE, :LIGHTSCREEN, :MAGICALLEAF, :PETALDANCE, :SAFEFUARD, :SKULLBASH],
  @moveset.tutor = [:BODYSLAM, :DOUBLEEDGE, :MIMIC, :SUBSTITUTE, :SWORDSDANCE]
  @evolutions = [
    {
      mode: :LEVEL,
      species: :IVYSAUR,
      argument: 16
    }
  ]
end
