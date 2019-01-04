class Pokemon
  attr_reader :exp
  attr_reader :ivs
  attr_reader :evs
  attr_reader :moves

  def initialize(species, level)
    validate species => [Symbol, Integer], level => Integer
    # Ensure the species exists and set some initial values
    species = Species.get(species)
    @species_intname = species.intname
    @exp = EXP.get_exp(species.leveling_rate, level)
    @ability_index = rand(0..1) # Slot 1 or 2
    @nature_intname = Nature.random
    @ivs = Stats.new
    @ivs.hp = rand(32)
    @ivs.attack = rand(32)
    @ivs.defense = rand(32)
    @ivs.spatk = rand(32)
    @ivs.spdef = rand(32)
    @ivs.speed = rand(32)
    @evs = Stats.new
    @evs.hp = 0
    @evs.attack = 0
    @evs.defense = 0
    @evs.spatk = 0
    @evs.spdef = 0
    @evs.speed = 0
    @hp = fullhp
    @moves = []
    set_initial_moves
  end

  def species
    return Species.get(@species_intname)
  end

  def set_initial_moves
    moveset = species.moveset.level
    keys = moveset.keys.select { |k| k <= level }
    keys.reverse.each do |k|
      move = moveset[k]
      if move.is_a?(Array)
        move.each { |m| @moves.insert(0, UsableMove.new(m)) if @moves.size < 4 }
      else
        @moves.insert(0, UsableMove.new(move))
      end
      break if @moves.size >= 4
    end
  end

  def ability
    return Ability.get(@ability) if @ability
    if @ability_index == 1 && species.abilities.size == 1
      return Ability.get(species.abilities[0])
    else
      return Ability.get(species.abilities[@ability_index])
    end
  end

  def ability=(value)
    validate value => Symbol
    if Ability.exists?(value)
      @ability = value
    else
      raise "Invalid ability for #{value.inspect(50)}"
    end
  end

  def exp=(value)
    validate value => Integer
    @exp = value
  end

  def level
    return EXP.get_level(species.leveling_rate, @exp)
  end

  def level=(value)
    validate value => Integer
    @exp = EXP.get_exp(species.leveling_rate, value)
  end

  def nature
    return Nature.get(@nature_intname)
  end

  def nature=(value)
    validate value => Symbol
    if Nature.exists?(value)
      @nature_intname = value
    else
      raise "Invalid nature for #{value.inspect(50)}"
    end
  end

  def totalhp
    return (((2.0 * species.stats.hp + @ivs.hp + (@evs.hp / 4.0)) * level.to_f) / 100.0).floor + level + 10
  end
  alias fullhp totalhp

  def attack
    mod = 1.0
    mod = 1.1 if self.nature.buff == :attack
    mod = 0.9 if self.nature.debuff == :attack
    return (((((2.0 * species.stats.attack + @ivs.attack + (@evs.attack / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
  end
  alias atk attack

  def defense
    mod = 1.0
    mod = 1.1 if self.nature.buff == :defense
    mod = 0.9 if self.nature.debuff == :defense
    return (((((2.0 * species.stats.defense + @ivs.defense + (@evs.defense / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
  end
  alias def defense

  def spatk
    mod = 1.0
    mod = 1.1 if self.nature.buff == :spatk
    mod = 0.9 if self.nature.debuff == :spatk
    return (((((2.0 * species.stats.spatk + @ivs.spatk + (@evs.spatk / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
  end

  def spdef
    mod = 1.0
    mod = 1.1 if self.nature.buff == :spdef
    mod = 0.9 if self.nature.debuff == :spdef
    return (((((2.0 * species.stats.spdef + @ivs.spdef + (@evs.spdef / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
  end

  def speed
    mod = 1.0
    mod = 1.1 if self.nature.buff == :speed
    mod = 0.9 if self.nature.debuff == :speed
    return (((((2.0 * species.stats.speed + @ivs.speed + (@evs.speed / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
  end
  alias spd speed
end

p = Pokemon.new(:BULBASAUR, 100)
