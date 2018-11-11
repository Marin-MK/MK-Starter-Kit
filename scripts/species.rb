class Species
  # Stores the species
  List = []

  # These methods are defined on the species, but can also be directly
  # on a Pokemon object as a shortcut.
  # e.g. pokemon.weight instead of pokemon.species.weight (which still works)
  DELEGATED_PROPERTIES = [
    :id, :intname, :type1, :type2, :hidden_ability,
    :egg_groups, :height, :weight, :exp_yield, :growth_rate,
    :gender_ratio, :catch_rate, :pokedex_color, :pokedex_entry,
    :base_friendship, :tm_compatibility, :egg_moves, :tutor_moves,
    :evolutions
  ]

  # These methods are also defined on the species, but cannot be accessed
  # directly on Pokemon objects, because they have confusing or conflicting names
  # when used on Pokemon (e.g. #moves vs #moveset, #evs vs #ev_yield)
  # To use these, you have to normally access the species first: pokemon.species.moveset
  NONDELEGATED_PROPERTIES = [
    :name, :abilities, :hatch_time, :ev_yield, :moveset
  ]

  # Loads all species data from species.mkd and stores it in the List constant
  def self.load
    List.clear
    data = FileUtils.load_data('data/species.mkd')
    for i in 0...data.size
      List[i] = data[i]
      next if List[i].nil?
      const_set(data[i].intname, List[i])
    end
  end

  # Returns the species object based on the given internal name or ID. Crashes if not found.
  def self.get(species)
    s = self.try_get(species)
    return s if s
    raise "No species found for #{i = species.inspect; i.size > 32 ? i[0..32] + '...' : i}"
  end

  # Returns the species object based on the given internal name or ID.
  def self.try_get(species)
    validate species => [Fixnum, Symbol]
    return List.detect { |e| return e if e && (e.id == species || e.intname == species) }
  end

  attr_reader *DELEGATED_PROPERTIES
  attr_reader *NONDELEGATED_PROPERTIES

  #temp - should not have a constructor
  def initialize(id, &block)
    @id = id
    instance_eval(&block) if block
  end
end

=begin
#temp - should not exist
s = Species.new(1) do
  @intname = :BULBASAUR
  @name = "Bulbasaur"
  @type1 = :GRASS
  @type2 = :POISON
  @abilities = [:OVERGROW]
  @hidden_ability = :CHLOROPHYLL
  @egg_groups = [:MONSTER, :GRASS]
  @hatch_time = 5140..5396
  @height = 0.7
  @weight = 6.9
  @exp_yield = 64
  @growth_rate = :MEDIUMSLOW
  @gender_ratio = :FEMALEONEEIGHT
  @catch_rate = 45
  @ev_yield = [0,0,0,1,0,0]
  @pokedex_color = :GREEN
  @pokedex_entry = "There is a plant seed on its back right from the day this Pokémon is born. The seed slowly grows larger."
  @base_friendship = 70
  @moveset = {
    1 => :TACKLE,
    3 => :GROWL,
    7 => :LEECHSEED,
    9 => :VINEWHIP,
    13 => [:POISONPOWDER,:SLEEPPOWDER],
    15 => :TAKEDOWN,
    19 => :RAZORLEAF,
    21 => :SWEETSCENT,
    25 => :GROWTH,
    27 => :DOUBLEEDGE,
    31 => :WORRYSEED,
    33 => :SYNTHESIS,
    37 => :SEEDBOMB
  }
  @tm_compatibility = [:WORKUP,:TOXIC,:VENOSHOCk,:HIDDENPOWER,:SUNNYDAY,:LIGHTSCREEN,:PORTECT,
                       :SAFEGUARD,:FRUSTRATION,:SOLARBEAM,:RETURN,:DOUBLETEAM,:SLUDGEBOMB,:FACADE,
                       :REST,:ATTRACT,:ROUND,:ECHOEDVOICE,:ENERGYBALL,:SWORDSDANCE,:GRASSKNOT,
                       :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:NATUREPOWER,:CONFIDE]
  @egg_moves = [:AMNESIA,:CHARM,:CURSE,:ENDURE,:GIGADRAIN,:GRASSWHISTLE,:GRASSYTERRAIN,:INGRAIN,
                :LEAFSTORM,:MAGICALLEAF,:NATUREPOWER,:PETALDANCE,:POWERWHIP,:SKULLBASH,:SLUDGE]
  @tutor_moves = [:BIND,:GIGADRAIN,:GRASSPLEDGE,:KNOCKOFF,:SEEDBOMB,:SNORE,:SYNTHESIS,:WORRYSEED]
  @evolutions = {
    :level => {
      16 => :IVYSAUR
    }
  }
end

FileUtils.save_data('data/species.mkd', [nil, s])
=end

Species.load