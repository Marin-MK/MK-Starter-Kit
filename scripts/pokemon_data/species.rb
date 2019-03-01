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
  def name(form = 0)
    return @forms[form][:name] || @name if @forms[form] && form != 0
    return @name
  end

  # @return [Symbol] type 1 of the species.
  def type1(form = 0)
    return @forms[form][:type1] || @type1 if @forms[form] && form != 0
    return @type1
  end

  # @return [Symbol, NilClass] type 2 of the species
  def type2(form = 0)
    return @forms[form][:type2] || @type2 if @forms[form] && form != 0
    return @type2
  end

  # @return [Stats] the base statistics of the species.
  def stats(form = 0)
    return @forms[form][:stats] || @stats if @forms[form] && form != 0
    return @stats
  end

  # @return [Array<Symbol>] the possible abilities of the species.
  def abilities(form = 0)
    return @forms[form][:abilities] || @abilities if @forms[form] && form != 0
    return @abilities
  end

  # @return [Symbol, NilClass] the hidden ability of the species.
  def hidden_ability(form = 0)
    return @forms[form][:hidden_ability] || @hidden_ability if @forms[form] && form != 0
    return @hidden_ability
  end

  # @return [Stats] the EV Yield of the species.
  def ev_yield(form = 0)
    return @forms[form][:ev_yield] || @ev_yield if @forms[form] && form != 0
    return @ev_yield
  end

  # @return [Array<Symbol>] the egg groups of the species.
  def egg_groups(form = 0)
    return @forms[form][:egg_groups] || @egg_groups if @forms[form] && form != 0
    return @egg_groups
  end

  # @return [Float] the height of the species in kg.
  def height(form = 0)
    return @forms[form][:height] || @height if @forms[form] && form != 0
    return @height
  end

  # @return [Float] the weight of the species in m.
  def weight(form = 0)
    return @forms[form][:weight] || @weight if @forms[form] && form != 0
    return @weight
  end

  # @return [Integer] the Base EXP of the species.
  def base_exp(form = 0)
    return @forms[form][:base_exp] || @base_exp if @forms[form] && form != 0
    return @base_exp
  end

  # @return [Symbol] the leveling rate of the species.
  def leveling_rate(form = 0)
    return @forms[form][:leveling_rate] || @leveling_rate if @forms[form] && form != 0
    return @leveling_rate
  end

  # @return [Symbol] the gender ratio of the species.
  def gender_ratio(form = 0)
    return @forms[form][:gender_ratio] || @gender_ratio if @forms[form] && form != 0
    return @gender_ratio
  end

  # @return [Integer] the catch rate of the species.
  def catch_rate(form = 0)
    return @forms[form][:catch_rate] || @catch_rate if @forms[form] && form != 0
    return @catch_rate
  end

  # @return [Integer] the minimum number of steps it takes to hatch an egg of the species.
  def hatch_time(form = 0)
    return @forms[form][:hatch_time] || @hatch_time if @forms[form] && form != 0
    return @hatch_time
  end

  # @return [Symbol] the Pokedex color of the species.
  def pokedex_color(form = 0)
    return @forms[form][:pokedex_color] || @pokedex_color if @forms[form] && form != 0
    return @pokedex_color
  end

  # @return [String] the Pokedex entry of the species.
  def pokedex_entry(form = 0)
    return @forms[form][:pokedex_entry] || @pokedex_entry if @forms[form] && form != 0
    return @pokedex_entry
  end

  # @return [Integer] the initial happiness of pokemon of this species.
  def happiness(form = 0)
    return @forms[form][:happiness] || @happiness if @forms[form] && form != 0
    return @happiness
  end

  # @return [Moveset] the full moveset of the species.
  def moveset(form = 0)
    return @forms[form][:moveset] || @moveset if @forms[form] && form != 0
    return @moveset
  end

  # @return [Array<Hash>] all possible evolutions of the species.
  def evolutions(form = 0)
    return @forms[form][:evolutions] || @evolutions if @forms[form] && form != 0
    return @evolutions
  end

  # @return [Proc] the proc used to determine the form of the Pokemon upon creation.
  attr_reader :get_form_on_creation

  # Creates a new Species object.
  def initialize(&block)
    #validate block => Proc
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
    #validate_species
    Cache[@intname] = self
    self.class.const_set(@intname, self)
  end

  # @return [Integer] the Base Stat Total of the species' base stats.
  def bst
    return self.stats.hp + self.stats.attack + self.stats.defense + self.stats.spatk + self.stats.spdef + self.stats.speed
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
        @happiness => Integer,
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
    validate species => [Symbol, Integer, Species]
    return species if species.is_a?(Species)
    unless Species.exists?(species)
      raise "No species could be found for argument #{species.inspect(50)}"
    end
    return Species.try_get(species)
  end

  # @param species [Symbol, Integer] the species to look up.
  # @return [Species, NilClass]
  def self.try_get(species)
    validate species => [Symbol, Integer, Species]
    return species if species.is_a?(Species)
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
  @happiness = 70
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
  @moveset.tms = [:TOXIC, :BULLETSEED, :HIDDENPOWER, :SUNNYDAY, :PROTECT, :GIGADRAIN, :FRUSTRATION, :SOLARBEAM, :RETURN, :DOUBLETEAM, :SLUDGEBOMB, :FACADE, :SECRETPOWER, :REST, :ATTRACT, :CUT, :STRENGTH, :FLASH, :ROCKSMASH]
  @moveset.egg = [:CHARM, :CURSE, :GRASSWHISTLE, :LIGHTSCREEN, :MAGICALLEAF, :PETALDANCE, :SAFEFUARD, :SKULLBASH],
  @moveset.tutor = [:BODYSLAM, :DOUBLEEDGE, :MIMIC, :SUBSTITUTE, :SWORDSDANCE, :SOLARBEAM]
  @evolutions = [
    {
      mode: :LEVEL,
      species: :IVYSAUR,
      argument: 16
    }
  ]
  @get_form_on_creation = proc do |pokemon|
    next rand(2)
  end
  @forms = {
    1 => {
      name: "Boolbasaurus",
      type1: :FIGHTING,
      type2: :FLYING,
      leveling_rate: :FAST
    }
  }
end
