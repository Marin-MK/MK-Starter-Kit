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

  attr_reader :intname
  attr_reader :id
  attr_reader :name
  attr_reader :type1
  attr_reader :type2
  attr_reader :stats
  attr_reader :abilities
  attr_reader :hidden_ability
  attr_reader :ev_yield
  attr_reader :egg_groups
  attr_reader :height
  attr_reader :weight
  attr_reader :exp_yield
  attr_reader :leveling_rate
  attr_reader :gender_ratio
  attr_reader :catch_rate
  attr_reader :hatch_time
  attr_reader :pokedex_color
  attr_reader :pokedex_entry
  attr_reader :friendship
  attr_reader :moveset
  attr_reader :evolutions

  #temp (as in, is done by the editor and this method
  # will be removed or made inaccessible in the kit)
  def initialize(&block)
    validate block => Proc
    @id = 0
    @stats = Stats.new
    @stats.hp = @stats.attack = @stats.defense = @stats.spatk = @stats.spdef = @stats.speed = 0
    @ev_yield = Stats.new
    @ev_yield.hp = @ev_yield.attack = @ev_yield.defense = @ev_yield.spatk = @ev_yield.spdef = @ev_yield.speed = 0
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

  def bst
    return @stats.hp + @stats.attack + @stats.defense + @stats.spatk + @stats.spdef + @stats.speed
  end

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
        @exp_yield => Numeric,
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

  def self.get(species)
    validate species => [Symbol, Integer]
    unless Species.exists?(species)
      raise "No species could be found for argument #{species.inspect(50)}"
    end
    return Species.try_get(species)
  end

  def self.try_get(species)
    validate species => [Symbol, Integer]
    return Cache[species] if species.is_a?(Symbol)
    return Cache.values.find { |s| s.id == species }
  end

  def self.exists?(species)
    validate species => [Symbol, Integer]
    return Cache.has_key?(species) if species.is_a?(Symbol)
    return Cache.values.any? { |s| s.id == species }
  end

  def self.random
    return Cache.keys.sample
  end
end

# This would be loaded from a data file
Species.new do
  @intname = :BULBASAUR
  @id = 1
  @name = "Bulbasaur"
  @type1 = :GRASS
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
  @exp_yield = 64
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
