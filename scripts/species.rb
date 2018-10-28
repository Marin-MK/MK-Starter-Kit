class Species
  List = []

  # using Module#delegate, these properties are defined on a species,
  # but can also be accessed as methods of Pokemon,
  # for example pokemon.weight instead of pokemon.species.weight

  DELEGATED_PROPERTIES = [
    :id, :intname, :type1, :type2, :hidden_ability,
    :egg_groups, :height, :weight, :exp_yield, :growth_rate,
    :gender_ratio, :catch_rate, :pokedex_color, :pokedex_entry,
    :base_friendship, :tm_compatibility, :egg_moves, :tutor_moves,
    :evolutions
  ]

  # these don't really make sense on an individual pokemon
  # and/or have confusing names given other properties (#moves vs #moveset)
  # so they're only available on a species
  # to get them on a pokemon, use
  # pokemon.species.some_method

  NONDELEGATED_PROPERTIES = [
    :name, :abilities, :hatch_time, :ev_yield, :moveset
  ]

  # Loads all species data from species.mkd
  def self.load
    List.clear
    data = FileUtils.load_data('data/species.mkd')
    for i in 0...data.size
      List[i] = data[i]
      next if List[i].nil?
      const_set(data[i].intname, List[i])
    end
  end

  def self.get(species)
    s = self.try_get(species)
    return s if s
    raise "No species found for #{i = species.inspect; i.size > 32 ? i[0..32] + '...' : i}"
  end

  def self.try_get(species)
    validate species => [Fixnum, Symbol]
    return List.detect { |e| return e if e && (e.id == species || e.intname == species) }
  end

  attr_reader *DELEGATED_PROPERTIES
  attr_reader *NONDELEGATED_PROPERTIES

  def initialize(id, &block)
    @id = id
    instance_eval(&block) if block
  end
end

=begin
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