class Pokemon
  # @return [Integer] the total amount of HP this Pokemon can have.
  attr_reader :totalhp
  # @return [Integer] the current amount of HP this Pokemon has.
  attr_accessor :hp
  # @return [Integer] the total amount of Attack points this Pokemon has.
  attr_reader :attack
  # @return [Integer] the total amount of Defense points this Pokemon has.
  attr_reader :defense
  # @return [Integer] the total amount of Special Attack points this Pokemon has.
  attr_reader :spatk
  # @return [Integer] the total amount of Special Defense points this Pokemon has.
  attr_reader :spdef
  # @return [Integer] the total amount of Speed points this Pokemon has.
  attr_reader :speed
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
  # @return [String] the species name or nickname of this Pokemon.
  attr_accessor :name
  # @return [Integer] the happiness of this Pokemon.
  attr_accessor :happiness
  # @return [Symbol, NilClass] the status condition of this Pokemon.
  attr_accessor :status
  # @return [Symbol] the internal name of the ball used to catch this Pokemon.
  attr_accessor :ball_used
  # @return [Symbol] how this Pokemon was obtained.
  attr_accessor :obtain_mode
  # @return [String] the name of the original trainer of this Pokemon.
  attr_accessor :ot_name
  # @return [Integer] the gender of the original trainer of this Pokemon.
  attr_accessor :ot_gender

  # Creates a new Pokemon object.
  # @param species [Symbol, Integer] the species of the Pokemon.
  # @param level [Integer] the level of the Pokemon.
  def initialize(species, level, trainer = nil)
    validate species => [Symbol, Integer], level => Integer, trainer => [NilClass, Trainer]
    # Ensure the species exists and set some initial values
    species = Species.get(species)
    @species_intname = species.intname
    @form = 0
    if species.get_form_on_creation
      f = species.get_form_on_creation.call(self)
      @form = f || 0
    end
    @name = species.name(self.form)
    @exp = EXP.get_exp(species.leveling_rate(self.form), level)
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
    @happiness = species.happiness(self.form)
    @ball_used = :POKEBALL
    if trainer
      @ot_name = trainer.name
      @ot_gender = trainer.gender
    else
      @ot_name = nil
      @ot_gender = nil
    end
    @obtain_mode = :MET
    @obtain_time = Time.now
    @obtain_level = self.level
    @moves = get_moveset_for_level
    calc_stats
    @hp = @totalhp
  end

  # @return [Species] the species object associated with this Pokemon.
  def species
    return Species.get(@species_intname)
  end

  # @return [Integer] the form of the Pokemon.
  def form
    return @formflag if @formflag
    if species.get_form
      f = species.get_form.call(self)
      self.set_form(f) if f
    end
    return @form
  end

  # Naturally changes the Pokemon's form.
  # @param form [Integer] the new form of the Pokemon.
  def set_form(form)
    validate form => Integer
    unless @form == form
      @form = form
      # Update the Pokemon to reflect the form change
      self.calc_stats
    end
  end



  # Changes the amount of EXP this Pokemon has.
  # @param value [Integer] the new EXP amount.
  def exp=(value)
    validate value => Integer
    @exp = value
    if self.level < 1
      raise "A Pokemon can never be below level 1."
    end
    self.calc_stats
  end

  # @return [Integer] the level this Pokemon is currently at.
  def level
    return EXP.get_level(species.leveling_rate(self.form), @exp)
  end

  # Changes the level of this Pokemon.
  # @param value [Integer] the new level of this Pokemon.
  def level=(value)
    validate value => Integer
    if value < 1
      raise "A Pokemon can never be below level 1."
    end
    @exp = EXP.get_exp(species.leveling_rate(self.form), value)
    self.calc_stats
  end



  # @return [Item, NilClass] the item the Pokemon is holding.
  def item
    return nil unless @item
    return Item.get(@item)
  end

  # Gives the Pokemon an item to hold.
  # @param value [Symbol, NilClass] the item to give the Pokemon.
  def item=(value)
    validate value => [Symbol, NilClass]
    @item = value
  end

  # Gives the Pokemon an item to hold.
  # @param nature [Symbol, Integer, Item, NilClass] the item to give the Pokemon.
  def set_item(item)
    validate item => [Symbol, Integer, Item, NilClass]
    if item.nil?
      @item = nil
    else
      item = Item.get(item)
      @item = item.intname
    end
  end
  alias give_item set_item



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
    self.set_shiny(value)
  end

  # Forces a value for the Pokemon's shininess.
  # @param nature [Boolean, NilClass] the shininess value.
  def set_shiny(shiny)
    validate shiny => [Boolean, NilClass]
    @shinyflag = shiny
  end
  alias set_shininess set_shiny



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
    unless threshold.has_key?(species.gender_ratio(self.form))
      raise "Invalid Gender Ratio for species #{species.intname.inspect(50)}."
    end
    threshold = threshold[species.gender_ratio(self.form)]
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
    self.set_gender(value)
  end

  # Forces a value for the Pokemon's gender.
  # @param nature [Integer, NilClass] the gender value.
  def set_gender(value)
    validate value => [Integer, NilClass]
    raise "Invalid gender #{value.inspect(16)}" unless value == 0 || value == 1 || value == 2 || value.nil?
    @genderflag = value
  end



  # @return [Ability] the current ability of the Pokemon.
  def ability
    return Ability.get(@abilityflag) if @abilityflag
    idx = @pid % 2 # Ability index
    if idx == 1 && species.abilities(self.form).size == 1
      return Ability.get(species.abilities(self.form)[0])
    else
      return Ability.get(species.abilities(self.form)[idx])
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

  # Forces a value for the Pokemon's ability.
  # @param nature [Symbol, Integer, Ability, NilClass] the ability value.
  def set_ability(ability)
    validate ability => [Symbol, Integer, Ability, NilClass]
    if ability.nil?
      @abilityflag = nil
    else
      ability = Ability.get(ability)
      @abilityflag = ability.intname
    end
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

  # Forces a value for the Pokemon's nature.
  # @param nature [Symbol, Integer, Nature, NilClass] the nature value.
  def set_nature(nature)
    validate nature => [Symbol, Integer, Nature, NilClass]
    if nature.nil?
      @natureflag = nil
    else
      nature = Nature.get(nature)
      @natureflag = nature.intname
    end
  end



  # @return [Type] the first type of this Pokemon species.
  def type1
    return Type.get(species.type1(self.form))
  end

  # @return [Type, NilClass] the second type of this Pokemon species.
  def type2
    return nil if species.type2(self.form).nil? || species.type1(self.form) == species.type2(self.form)
    return Type.get(species.type2(self.form))
  end



  # @return [Array<UsableMove>] the moves this Pokemon would have at the current level.
  def get_moveset_for_level
    moves = []
    moveset = species.moveset(self.form).level
    keys = moveset.keys.select { |k| k <= level }
    keys.reverse.each do |k|
      move = moveset[k]
      if move.is_a?(Array)
        move.each { |m| moves.insert(0, UsableMove.new(m)) if moves.size < 4 }
      else
        moves.insert(0, UsableMove.new(move))
      end
      break if moves.size >= 4
    end
    return moves
  end

  # Whether or not it's somehow possible for this Pokemon to know the given move.
  # Includes TMs, eggmoves, tutor moves, moveset and evolution moves.
  # If this method returns false for a move but the Pokemon does know the move, it's an illegal Pokemon.
  # @return [Boolean] whether or not it's somehow possible for this Pokemon to know the given move.
  def can_know_move?(move)
    validate move => [Symbol, Integer, Move]
    move = Move.get(move)
    name = move.intname
    species.moveset(self.form).keys.each do |key|
      moves = species.moveset(self.form).get(key)
      if key == :level
        moves.each_value do |e|
          if e.is_a?(Array)
            return true if e.include?(name)
          else
            return true if e == name
          end
        end
      else
        return true if moves.include?(name)
      end
    end
    return false
  end

  # @return [Boolean] whether or not this Pokemon can learn the given move by TM or tutor.
  def can_learn_move?(move)
    validate move => [Symbol, Integer, Move]
    move = Move.get(move)
    name = move.intname
    return false if self.knows_move?(move)
    return species.moveset(self.form).tms.include?(name) || species.moveset(self.form).tutor.include?(name)
  end



  # Recalculates the stats.
  def calc_stats
    buff = self.nature.buff
    debuff = self.nature.debuff
    factor = nil
    if @hp && @totalhp
      factor = @hp / @totalhp.to_f
    end
    @totalhp = (((2.0 * species.stats(self.form).hp + @ivs.hp + (@evs.hp / 4.0)) * level.to_f) / 100.0).floor + level + 10
    @hp = (@totalhp * factor).round if factor
    mod = (buff == :attack ? 1.1 : debuff == :attack ? 0.9 : 1.0)
    @attack = (((((2.0 * species.stats(self.form).attack + @ivs.attack + (@evs.attack / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
    mod = (buff == :defense ? 1.1 : debuff == :defense ? 0.9 : 1.0)
    @defense = (((((2.0 * species.stats(self.form).defense + @ivs.defense + (@evs.defense / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
    mod = (buff == :spatk ? 1.1 : debuff == :spatk ? 0.9 : 1.0)
    @spatk = (((((2.0 * species.stats(self.form).spatk + @ivs.spatk + (@evs.spatk / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
    mod = (buff == :spdef ? 1.1 : debuff == :spdef ? 0.9 : 1.0)
    @spdef = (((((2.0 * species.stats(self.form).spdef + @ivs.spdef + (@evs.spdef / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
    mod = (buff == :speed ? 1.1 : debuff == :speed ? 0.9 : 1.0)
    @speed = (((((2.0 * species.stats(self.form).speed + @ivs.speed + (@evs.speed / 4.0)) * level.to_f) / 100.0).floor + 5) * mod).floor
  end

  alias atk attack
  alias def defense
  alias defence defense
  alias specialattack spatk
  alias special_attack spatk
  alias specialdefense spdef
  alias special_defense spdef
  alias specialdefence spdef
  alias special_defence spdef
  alias spd speed

  #============================================================================#
  # Utility methods
  #============================================================================#
  # @return [Boolean] whether or not the Pokemon has the given type as its first or second type.
  def has_type?(type)
    validate type => [Symbol, Integer, Type]
    type = Type.get(type)
    return self.type1 == type || self.type2 == type
  end

  # @return [Boolean] whether or not the Pokemon has the given ability.
  def has_ability?(ability)
    validate ability => [Symbol, Integer, Ability]
    ability = Ability.get(ability)
    return self.ability == ability
  end

  # @return [Boolean] whether or not the Pokemon has the given nature.
  def has_nature?(nature)
    validate nature => [Symbol, Integer, Nature]
    nature = Nature.get(nature)
    return self.nature == nature
  end

  # @return [Boolean] whether or not the Pokemon is holding the given item or an item at all.
  def has_item?(item = nil)
    validate item => [Symbol, Integer, Item, NilClass]
    if item.nil?
      return !self.item.nil?
    end
    item = Item.get(item)
    return self.item == item
  end

  # @return [Boolean] whether or not the Pokemon knows the given move.
  def has_move?(move)
    validate move => [Symbol, Integer, Move]
    move = Move.get(move)
    return self.moves.any? { |e| e.intname == move.intname }
  end
  alias knows_move? has_move?

  # @return [Boolean] whether or not the Pokemon is of the given gender.
  def is_gender?(gender)
    validate gender => Integer
    raise "Invalid gender #{gender.inspect(16)}" unless gender == 0 || gender == 1 || gender == 2
    return self.gender == gender
  end

  # @return [Boolean] whether or not the Pokemon is male.
  def male?
    return self.is_gender?(0)
  end

  # @return [Boolean] whether or not the Pokemon is female.
  def female?
    return self.is_gender?(1)
  end

  # @return [Boolean] whether or not the Pokemon is genderless.
  def genderless?
    return self.is_gender?(2)
  end

  # Restores the Pokemon's HP.
  def heal_hp
    self.hp = self.totalhp
  end

  # Clears the Pokemon's status.
  def heal_status
    self.status = nil
  end

  # Heals the Pokemon's move PP.
  def heal_pp
    self.moves.each { |e| e.heal_pp }
  end

  # Fully heals the Pokemon.
  def heal
    self.heal_hp
    self.heal_status
    self.heal_pp
  end

  # @return [Boolean] whether or not the Pokemon is fainted.
  def fainted?
    return self.hp <= 0
  end
end
