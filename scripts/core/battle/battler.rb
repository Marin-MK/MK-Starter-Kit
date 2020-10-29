class Battle
  BattleStats = Struct.new(:attack, :defense, :spatk, :spdef, :speed, :accuracy, :evasion)

  class Battler
    attr_accessor :battle
    attr_accessor :ui
    attr_accessor :pokemon
    attr_accessor :effects
    attr_accessor :battle
    attr_accessor :stages
    attr_accessor :index
    attr_accessor :side
    attr_accessor :wild_pokemon
    attr_accessor :last_move_index

    # Create a new Battler object by wrapping a Pokémon object
    # @param battle [Battle] the battle object associated with the battler
    # @param pokemon [Pokemon] the Pokémon object that this battler wraps
    def initialize(battle, pokemon)
      validate \
          battle => Battle,
          pokemon => Pokemon
      @battle = battle
      @pokemon = pokemon
      @wild_pokemon = false
      @bad_poison_counter = nil
      # The effects hash that tracks effects applying to this battler.
      @effects = {}
      # Initialize @stages as what tracks our in-battle stat stages.
      @stages = BattleStats.new
      @stages.attack = 0
      @stages.defense = 0
      @stages.spatk = 0
      @stages.spdef = 0
      @stages.speed = 0
      @stages.accuracy = 0
      @stages.evasion = 0
      # The index of the last-used move.
      @last_move_index = 0
    end

    # @return [String] the display name of this battler.
    def name
      return @wild_pokemon ? "Wild " + @pokemon.name : @pokemon.name
    end

    # @return [Integer] the level of this battler.
    def level
      return @pokemon.level
    end

    # @return [Integer] the exp of this battler.
    def exp
      return @pokemon.exp
    end

    # @return [Species] the species of this battler.
    def species
      return @pokemon.species
    end

    # @return [Array<UsableMove>] the moves of this battler.
    def moves
      return @pokemon.moves
    end

    # @return [Array<Type>] the types of this battler.
    def types
      return [@pokemon.type1] if @pokemon.type2.nil?
      return [@pokemon.type1, @pokemon.type2]
    end

    # @return [Integer] the effective HP of this battler.
    def hp
      return @pokemon.hp
    end

    # @return [Integer] the attack stat of this Pokémon.
    def base_attack
      return @pokemon.attack
    end

    # @return [Integer] the effective attack stat of this battler.
    def attack
      if @stages.attack < -6 || @stages.attack > 6
        raise "Invalid attack stage: #{@stages.attack}"
      end
      return (base_attack * GENERIC_STAGE_MULTIPLIER[@stages.attack + 6]).floor
    end

    # @return [Integer] the defense stat of this Pokémon.
    def base_defense
      return @pokemon.defense
    end

    # @return [Integer] the effective defense stat of this battler.
    def defense
      if @stages.defense < -6 || @stages.defense > 6
        raise "Invalid defense stage: #{@stages.defense}"
      end
      return (base_defense * GENERIC_STAGE_MULTIPLIER[@stages.defense + 6]).floor
    end

    # @return [Integer] the special attack stat of this Pokémon.
    def base_spatk
      return @pokemon.spatk
    end

    # @return [Integer] the effective special attack stat of this battler.
    def spatk
      if @stages.spatk < -6 || @stages.spatk > 6
        raise "Invalid spatk stage: #{@stages.spatk}"
      end
      return (base_spatk * GENERIC_STAGE_MULTIPLIER[@stages.spatk + 6]).floor
    end

    # @return [Integer] the special defense stat of this Pokémon.
    def base_spdef
      return @pokemon.spdef
    end

    # @return [Integer] the effective special defense stat of this battler.
    def spdef
      if @stages.spdef < -6 || @stages.spdef > 6
        raise "Invalid spdef stage: #{@stages.spdef}"
      end
      return (base_spdef * GENERIC_STAGE_MULTIPLIER[@stages.spdef + 6]).floor
    end

    # @return [Integer] the speed stat of this Pokémon.
    def base_speed
      return @pokemon.speed
    end

    # @return [Integer] the effective speed of this battler.
    def speed
      if @stages.speed < -6 || @stages.speed > 6
        raise "Invalid speed stage: #{@stages.speed}"
      end
      return (base_speed * GENERIC_STAGE_MULTIPLIER[@stages.speed + 6]).floor
    end

    # @return [Integer] the accuracy stage of this battler.
    def accuracy_stage
      return @stages.accuracy
    end

    # @return [Integer] the evasion stage of this battler.
    def evasion_stage
      return @stages.evasion
    end

    # @return [Symbol] the ball used to capture this Pokémon.
    def ball_used
      return @pokemon.ball_used
    end

    # @return [Integer] the total HP of this Pokémon.
    def totalhp
      return @pokemon.totalhp
    end

    # @return [Boolean] whether this Pokémon is male.
    def male?
      return @pokemon.male?
    end

    # @return [Boolean] whether this Pokémon is female.
    def female?
      return @pokemon.female?
    end

    # @return [Boolean] whether this Pokémon is genderless.
    def genderless?
      return @pokemon.genderless?
    end

    # @return [Boolean] whether this Pokémon is shiny.
    def shiny?
      return @pokemon.shiny?
    end

    # @return [Boolean] whether this Pokémon is fainted.
    def fainted?
      return @pokemon.fainted?
    end

    # @return [Boolean] whether this Pokémon is an egg.
    def egg?
      return @pokemon.egg?
    end

    # Gets whether this battler has a certain type.
    # @param type [Type] the type to test for.
    # @return [Boolean] whether the battler has the given type.
    def has_type?(type)
      validate type => [Symbol, Integer, Type]
      return @pokemon.has_type?(type)
    end

    # @return [Symbol] the status condition of this Pokémon.
    def status
      return @pokemon.status
    end

    # @return [Boolean] whether the Pokémon has a status condition.
    def has_status?
      return !@pokemon.status.nil?
    end

    # Burns the Pokémon.
    def burn
      if burned?
        message("#{self.name} is already\nburned!")
      elsif has_status?
        message("But it failed!")
      else
        @pokemon.status = :burned
        @ui.update_status(self)
        message("#{self.name} was burned!")
      end
    end

    # @return [Boolean] whether the Pokémon is burned.
    def burned?
      return @pokemon.status == :burned
    end

    # Freezes the Pokémon.
    def freeze
      if frozen?
        message("#{self.name} is already\nfrozen!")
      elsif has_status?
        message("But it failed!")
      else
        @pokemon.status = :frozen
        @ui.update_status(self)
        message("#{self.name} was frozen solid!")
      end
    end

    # @return [Boolean] whether the Pokémon is frozen.
    def frozen?
      return @pokemon.status == :frozen
    end

    # Paralyzes the Pokémon.
    def paralyze
      if paralyzed?
        message("#{self.name} is already\nparalyzed!")
      elsif has_status?
        message("But it failed!")
      else
        @pokemon.status = :paralyzed
        @ui.update_status(self)
        message("#{self.name} was paralyzed!")
      end
    end

    # @return [Boolean] whether the Pokémon is paralyzed.
    def paralyzed?
      return @pokemon.status == :paralyzed
    end

    # Poisons the Pokémon.
    # @param bad [Boolean] whether the poison type is bad poison.
    def poison(bad = false)
      if poisoned?
        message("#{self.name} is already\npoisoned.")
      elsif has_status?
        message("But it failed!")
      else
        @pokemon.status = :poisoned
        @ui.update_status(self)
        message("#{self.name} was #{bad ? "badly " : ""}poisoned!")
        raise "Bad Poison not yet implemented" if bad
      end
    end

    # @return [Boolean] whether the Pokémon is poisoned.
    def poisoned?
      return @pokemon.status == :poisoned
    end

    # Makes the Pokémon fall asleep.
    def sleep
      if asleep?
        message("#{self.name} is already\nasleep!")
      elsif has_status?
        message("But it failed!")
      else
        @pokemon.status = :asleep
        @ui.update_status(self)
        message("#{self.name} fell asleep!")
      end
    end

    # @return [Boolean] whether this Pokémon is asleep.
    def asleep?
      return @pokemon.status == :asleep
    end

    # Shows a text message.
    # @param text [String] the text to display.
    # @param await_input [Boolean] whether to end the message without needing input.
    # @param ending_arrow [Boolean] whether the message should have a moving down arrow.
    # @param reset [Boolean] whether the message box should clear after the message is done.
    def message(msg, await_input = false, ending_arrow = false, reset = true)
      @battle.message(msg, await_input, ending_arrow, reset)
    end

    # Returns the opposing side.
    # @return [Side] the side opposite this battler.
    def opposing_side
      return @battle.sides[1 - @side]
    end

    # Calculates the exp to be gained by this battler given a defeated battler.
    # @param defeated_battler [Battler] the battler that was defeated
    # @return [Integer] the exp to be gained by this battler.
    def calculate_exp_gain(defeated_battler)
      validate defeated_battler => Battler
      # Trainer/Wild Pokemon difference
      a = 1
      # Defeated's Base EXP
      b = defeated_battler.pokemon.species.base_exp
      # Lucky Egg
      e = 1
      # Affection
      f = 1
      # Defeated's level
      defeatedlevel = defeated_battler.level
      # Winner's level
      playerlevel = self.level
      # Pass Power, O-Power, Roto Power, etc.
      p = 1
      # Participation in battle or not
      s = 1
      # OT
      t = 1
      # Past evolution level
      v = 1
      exp = (a * b * defeatedlevel / (5 * s) * ((2 * defeatedlevel + 10) ** 2.5 / (defeatedlevel + playerlevel + 10) ** 2.5) + 1) * t * e * p
      return exp.floor
    end

    # Gives this battler a certain amount of exp.
    # @param exp [Integer] the amount of exp to give to this battler.
    def gain_exp(exp)
      validate exp => Integer
      # Unsupported for opposing Pokémon
      if self.side == 1
        @pokemon.exp += exp
        return
      end
      message("#{self.name} gained\n#{exp} EXP. Points!", true, true, false)
      # Record the starting and destination level.
      startlevel = self.level
      rate = @pokemon.species.leveling_rate
      destlevel = EXP.get_level(rate, self.exp + exp)
      # For each level in between the final and current level
      for i in startlevel..destlevel
        # Calculate the exp gained between this level and the next level
        nextexp = EXP.get_exp(rate, i + 1)
        diffexp = nextexp - self.exp
        diffexp = exp if diffexp > exp
        exp -= diffexp
        if diffexp > 0
          # Show the exp gain
          @ui.gain_exp(self, diffexp)
          oldstats = [@pokemon.totalhp, @pokemon.attack, @pokemon.defense, @pokemon.spatk, @pokemon.spdef, @pokemon.speed]
          # Actually apply the exp increase
          @pokemon.exp += diffexp
          # If the new level is not the destination level
          if i != destlevel
            # Calculate the Pokémon's new stats
            @pokemon.calc_stats
            # Show the level up animation
            @ui.level_up(self)
            message("#{self.name} grew to\nLV. #{i + 1}!", true, true, false)
            newstats = [@pokemon.totalhp, @pokemon.attack, @pokemon.defense, @pokemon.spatk, @pokemon.spdef, @pokemon.speed]
            # Show the difference in stats
            @ui.stats_up_window(self, oldstats, newstats)
          end
        end
      end
    end

    # Faints this battler.
    def faint
      return if @shown_fainted
      # Show this battler fainting.
      @ui.faint(self)
      message("#{self.name}\nfainted!", true, true)
      # Give the opposing side exp for defeating this battler.
      opposing_side.distribute_exp(self)
      @shown_fainted = true
    end

    # Make this battler attempt an escape.
    # @param opponent [Battler] the opposing battler to compare speed with.
    # @return [Boolean] whether or not this battler escaped.
    def attempt_to_escape(opponent)
      validate opponent => Battler
      a = @pokemon.speed
      b = [1, opponent.pokemon.speed].max
      c = @battle.run_attempts
      if a > b # Faster than opponent
        chance = 256 # Always suceeds
      else
        chance = (a * 128) / b + 30 * c
        chance %= 256
      end
      @battle.run_attempts += 1
      if rand(0..255) < chance
        message("Got away safely!", true, true)
        return true
      else
        message("Can't escape!", true, true)
        return false
      end
    end

    # The effects applied to this battler at the end of a round.
    def end_of_turn
      if poisoned?
        message("#{self.name} is hurt\nby poison!")
        lower_hp(totalhp / 8)
      elsif burned?
        message("#{self.name} is hurt\nby its burn!")
        lower_hp(totalhp / 16)
      end
    end

    # Lower this battler's HP.
    # @param damage [Integer] the damage to apply to this battler.
    def lower_hp(damage)
      validate damage => [Integer, Float]
      damage = damage.floor
      damage = @pokemon.hp if damage > @pokemon.hp
      return if damage <= 0
      # Show the HP bar going down
      @ui.lower_hp(self, damage)
      # Apply the HP change
      @pokemon.hp -= damage
    end

    # Gets the value of a stage given a sybol.
    # @param stat [Symbol] the stat symbol to get the stage value of
    # @return [Integer] the stage of the given stat.
    def get_stage(stat)
      validate stat => Symbol
      if ![:attack, :defense, :spatk, :spdef, :speed, :accuracy, :evasion].include?(stat)
        raise "Invalid stat '#{stat}': must be one of [:attack, :defense, :spatk, :spdef, :speed, :accuracy, :evasion]"
      end
      return @stages.method(stat).call
    end

    # Sets the value of a stage given a symbol to a given value.
    # @param stat [Symbol] the stat symbol to set the stage value of
    # @param value [Integer] the new value of the stat stage.
    def set_stage(stat, value)
      validate \
          stat => Symbol,
          value => Integer
      if ![:attack, :defense, :spatk, :spdef, :speed, :accuracy, :evasion].include?(stat)
        raise "Invalid stat '#{stat}': must be one of [:attack, :defense, :spatk, :spdef, :speed, :accuracy, :evasion]"
      end
      @stages.method(stat.to_s + "=").call(value)
    end

    # Lower a stat stage.
    # @param stat [Symbol] the stat stage to lower
    # @param stages [Integer] the number of stages to lower the stat by
    # @param animation [Boolean] whether to show the stat lower animation
    # @param fail_message [Boolean] whether to show a message if the stat could not be lowered
    # @param success_message [Boolean] whether to show a message if the stat was lowered
    def lower_stat(stat, stages, animation = true, fail_message = true, success_message = true)
      validate \
          stat => Symbol,
          stages => Integer,
          animation => Boolean,
          fail_message => Boolean,
          success_message => Boolean
      current_stage = get_stage(stat)
      # Get the display name of the stat.
      statname = {
        attack: "ATTACK",
        defense: "DEFENSE",
        spatk: "SPATK",
        spdef: "SPDEF",
        speed: "SPEED",
        accuracy: "ACCURACY",
        evasion: "EVASION"
      }[stat]
      # If the stage is already at its minimum
      if current_stage <= -6
        # Show fail message if enabled
        message("#{self.name}'s #{statname}\nwon't go any lower!") if fail_message
      else
        # Lower the specified stat stage
        new_stage = current_stage - stages
        new_stage = -6 if new_stage < -6
        # Set the stat stage to the new amount
        set_stage(stat, new_stage)
        diff = current_stage - new_stage
        if animation
          # Show a stat down animation if enabled
          @ui.stat_anim(self, :red, :down)
        end
        if success_message
          # Show a success message if enabled
          if diff == 1
            message("#{self.name}'s #{statname}\nfell!")
          elsif diff == 2
            message("#{self.name}'s #{statname}\nharsly fell!")
          elsif diff >= 3
            message("#{self.name}'s #{statname}\nseverely fell!")
          end
        end
      end
    end
  end
end
