class Pokemon
  # @return [Integer] the amount of EXP this Pokemon has.
  attr_reader :exp
  # @return [Stats] the IV statistics of this Pokemon.
  attr_reader :ivs
  # @return [Stats] the EV statistics of this Pokemon.
  attr_reader :evs
  # @return [Array<UsableMove>] the moves this Pokemon currently knows.
  attr_reader :moves
  # @return [Integer] the personal ID of this Pokemon.
  attr_reader :pid

  # Creates a new Pokemon object.
  # @param species [Symbol, Integer] the species of the Pokemon.
  # @param level [Integer] the level of the Pokemon.
  def initialize(species, level)
    validate species => [Symbol, Integer], level => Integer
    # Ensure the species exists and set some initial values
    species = Species.get(species)
    @species_intname = species.intname
    @exp = EXP.get_exp(species.leveling_rate, level)
    @pid = rand(2 ** 32)
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

  # @return [Species] the species object associated with this Pokemon.
  def species
    return Species.get(@species_intname)
  end

  # Sets the initial moves for this Pokemon based on its current level.
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


  # @return [Boolean] whether or not the Pokemon is shiny.
  def shiny
    return @shinyflag if @shinyflag
    p1 = (@pid / 65536.0).floor
    p2 = @pid % 65536
    tid = $trainer.pid
    sid = $trainer.secret_id
    s = tid ^ sid ^ p1 ^ p2
    return s < SHINYCHANCE
  end

  # Forces a value for the Pokemon's shininess.
  # @param value [Boolean, NilClass] the shininess value.
  def shiny=(value)
    validate value => [Boolean, NilClass]
    @shinyflag = value
  end


  # @return [Integer] the gender of the Pokemon.
  def gender
    return @genderflag if @genderflag
    threshold = {
      :GENDERLESS => 255,
      :ALWAYSFEMALE => 254,
      :FEMALESEVENEIGHTH => 225,
      :FEMALETHREEFOURTH => 191,
      :FEMALEONESECOND => 127,
      :FEMALEONEFOURTH => 63,
      :FEMALEONEEIGHTH => 31,
      :ALWAYSMALE => 0
    }
    unless threshold.has_key?(species.gender_ratio)
      raise "Invalid Gender Ratio for species #{species.intname.inspect(50)}."
    end
    threshold = threshold[species.gender_ratio]
    return 2 if threshold == 255
    return 1 if threshold == 254
    return 0 if threshold == 0
    pgender = @pid % 256
    if pgender >= threshold
      return 0
    else
      return 1
    end
  end

  # Forces a value for the Pokemon's gender.
  # @param value [Integer, NilClass] the gender value.
  def gender=(value)
    validate value => [Integer, NilClass]
    raise "Invalid gender #{value.inspect(50)}" unless value == 0 || value == 1 || value == 2 || value.nil?
    @genderflag = value
  end



  # @return [Ability] the current ability of the Pokemon.
  def ability
    return Ability.get(@abilityflag) if @abilityflag
    idx = @pid % 2 # Ability index
    if idx == 1 && species.abilities.size == 1
      return Ability.get(species.abilities[0])
    else
      return Ability.get(species.abilities[idx])
    end
  end

  # Forces a value for the Pokemon's ability.
  # @param value [Symbol, NilClass] the ability value.
  def ability=(value)
    validate value => [Symbol, NilClass]
    if value.nil? || Ability.exists?(value)
      @abilityflag = value
    else
      raise "Invalid ability for #{value.inspect(50)}"
    end
  end



  # Changes the amount of EXP this Pokemon has.
  # @param value [Integer] the new EXP amount.
  def exp=(value)
    validate value => Integer
    @exp = value
  end



  # @return [Integer] the level this Pokemon is currently at.
  def level
    return EXP.get_level(species.leveling_rate, @exp)
  end

  # Changes the level of this Pokemon.
  # @param value [Integer] the new level of this Pokemon.
  def level=(value)
    validate value => Integer
    @exp = EXP.get_exp(species.leveling_rate, value)
  end



  # @return [Nature] the nature of the Pokemon.
  def nature
    return Nature.get(@natureflag) if @natureflag
    return Nature.get(@pid % Nature.count + 1)
  end

  # Forces a value for the Pokemon's nature.
  # @param value [Symbol, NilClass] the nature value.
  def nature=(value)
    validate value => [Symbol, NilClass]
    if value.nil? || Nature.exists?(value)
      @natureflag = value
    else
      raise "Invalid nature for #{value.inspect(50)}"
    end
  end



  # @return [Type] the first type of this Pokemon species.
  def type1
    return Type.get(species.type1)
  end

  # @return [Type, NilClass] the second type of this Pokemon species.
  def type2
    return nil if species.type2.nil? || species.type1 == species.type2
    return Type.get(species.type2)
  end



  # @return [Integer] the total amount of HP this Pokemon has.
  def totalhp
    return (((2.0 * species.stats.hp + @ivs.hp + (@evs.hp / 4.0)) * level.to_f) / 100.0).floor + level + 10
  end
  alias fullhp totalhp

  # @return [Integer] the total amount of Attack points this Pokemon has.
  def attack
    mod = 1.0
    mod = 1.1 if self.nature.buff == :attack
    mod = 0.9 if self.nature.debuff == :attack
    return (((((2.0 * species.stats.attack + @ivs.attack + (@evs.attack / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
  end
  alias atk attack

  # @return [Integer] the total amount of Defense points this Pokemon has.
  def defense
    mod = 1.0
    mod = 1.1 if self.nature.buff == :defense
    mod = 0.9 if self.nature.debuff == :defense
    return (((((2.0 * species.stats.defense + @ivs.defense + (@evs.defense / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
  end
  alias def defense
  alias defence defense

  # @return [Integer] the total amount of Special Attack points this Pokemon has.
  def spatk
    mod = 1.0
    mod = 1.1 if self.nature.buff == :spatk
    mod = 0.9 if self.nature.debuff == :spatk
    return (((((2.0 * species.stats.spatk + @ivs.spatk + (@evs.spatk / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
  end
  alias specialattack spatk

  # @return [Integer] the total amount of Special Defense points this Pokemon has.
  def spdef
    mod = 1.0
    mod = 1.1 if self.nature.buff == :spdef
    mod = 0.9 if self.nature.debuff == :spdef
    return (((((2.0 * species.stats.spdef + @ivs.spdef + (@evs.spdef / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
  end
  alias specialdefense spdef
  alias specialdefence spdef

  # @return [Integer] the total amount of Speed points this Pokemon has.
  def speed
    mod = 1.0
    mod = 1.1 if self.nature.buff == :speed
    mod = 0.9 if self.nature.debuff == :speed
    return (((((2.0 * species.stats.speed + @ivs.speed + (@evs.speed / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
  end
  alias spd speed



  #============================================================================#
  # Utility methods
  #============================================================================#
  def has_type?(type)
    validate type => [Symbol, Integer]
    type = Type.get(type)
    return self.type1 == type || self.type2 == type
  end

  def male?
    return self.gender == 0
  end

  def female?
    return self.gender == 1
  end

  def genderless?
    return self.gender == 2
  end
end
