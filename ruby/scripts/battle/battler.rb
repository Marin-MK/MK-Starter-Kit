class Battle
  BattleStats = Struct.new(:attack, :defense, :spatk, :spdef, :speed, :accuracy, :evasion)

  class Battler
    attr_accessor :battle
    attr_accessor :pokemon
    attr_accessor :effects
    attr_accessor :battle
    attr_accessor :stages
    attr_accessor :index
    attr_accessor :side
    attr_accessor :wild_pokemon

    def initialize(battle, pokemon)
      @battle = battle
      @pokemon = pokemon
      @wild_pokemon = false
      @effects = {}
      @stages = BattleStats.new
      @stages.attack = 0
      @stages.defense = 0
      @stages.spatk = 0
      @stages.spdef = 0
      @stages.speed = 0
      @stages.accuracy = 0
      @stages.evasion = 0
    end

    def name
      return @wild_pokemon ? "Wild " + @pokemon.name : @pokemon.name
    end

    def level
      return @pokemon.level
    end

    def exp
      return @pokemon.exp
    end

    def species
      return @pokemon.species
    end

    def moves
      return @pokemon.moves
    end

    def types
      return [@pokemon.type1] if @pokemon.type2.nil?
      return [@pokemon.type1, @pokemon.type2]
    end

    def hp
      return @pokemon.hp
    end

    def base_attack
      return @pokemon.attack
    end

    def attack
      if @stages.attack < -6 || @stages.attack > 6
        raise "Invalid attack stage: #{@stages.attack}"
      end
      return (base_attack * GENERIC_STAGE_MULTIPLIER[@stages.attack + 6]).floor
    end

    def base_defense
      return @pokemon.defense
    end

    def defense
      if @stages.defense < -6 || @stages.defense > 6
        raise "Invalid defense stage: #{@stages.defense}"
      end
      return (base_defense * GENERIC_STAGE_MULTIPLIER[@stages.defense + 6]).floor
    end

    def base_spatk
      return @pokemon.spatk
    end

    def spatk
      if @stages.spatk < -6 || @stages.spatk > 6
        raise "Invalid spatk stage: #{@stages.spatk}"
      end
      return (base_spatk * GENERIC_STAGE_MULTIPLIER[@stages.spatk + 6]).floor
    end

    def base_spdef
      return @pokemon.spdef
    end

    def spdef
      if @stages.spdef < -6 || @stages.spdef > 6
        raise "Invalid spdef stage: #{@stages.spdef}"
      end
      return (base_spdef * GENERIC_STAGE_MULTIPLIER[@stages.spdef + 6]).floor
    end

    def base_speed
      return @pokemon.speed
    end

    def speed
      if @stages.speed < -6 || @stages.speed > 6
        raise "Invalid speed stage: #{@stages.speed}"
      end
      return (base_speed * GENERIC_STAGE_MULTIPLIER[@stages.speed + 6]).floor
    end

    def accuracy
      if @stages.accuracy < -6 || @stages.accuracy > 6
        raise "Invalid accuracy stage: #{@stages.accuracy}"
      end
      return ACCURACY_EVASION_STAGE_MULTIPLIER[@stages.accuracy + 6]
    end

    def evasion
      if @stages.evasion < -6 || @stages.evasion > 6
        raise "Invalid evasion stage: #{@stages.evasion}"
      end
      return ACCURACY_EVASION_STAGE_MULTIPLIER[@stages.evasion + 6]
    end

    def ball_used
      return @ball_used
    end

    def totalhp
      return @pokemon.totalhp
    end

    def male?
      return @pokemon.male?
    end

    def female?
      return @pokemon.female?
    end

    def genderless?
      return @pokemon.genderless?
    end

    def shiny?
      return @pokemon.shiny?
    end

    def fainted?
      return @pokemon.fainted?
    end

    def egg?
      return @pokemon.egg?
    end

    def has_type?(type)
      return @pokemon.has_type?(type)
    end

    def burned?
      return @pokemon.status == :burned
    end

    def frozen?
      return @pokemon.status == :frozen
    end

    def paralyzed?
      return @pokemon.status == :paralyzed
    end

    def poisoned?
      return @pokemon.status == :poisoned
    end

    def asleep?
      return @pokemon.status == :asleep
    end

    def message(msg, await_input = false, ending_arrow = false, reset = true)
      @battle.message(msg, await_input, ending_arrow, reset)
    end

    def opposing_side
      return @battle.sides[1 - @side]
    end

    def calculate_exp_gain(defeated_battler)
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
      playerlevel = battler.level
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

    def gain_exp(exp)
      # Unsupported for opposing Pokémon
      if self.side == 1
        @pokemon.exp += exp
        return
      end
      message("#{self.name} gained\n#{exp} EXP. Points!", true, true, false)
      startlevel = self.level
      rate = @pokemon.species.leveling_rate
      destlevel = EXP.get_level(rate, self.exp + exp)
      for i in startlevel..destlevel
        nextexp = EXP.get_exp(rate, i + 1)
        diffexp = nextexp - self.exp
        diffexp = exp if diffexp > exp
        exp -= diffexp
        if diffexp > 0
          @battle.ui.gain_exp(self, diffexp)
          oldstats = [@pokemon.totalhp, @pokemon.attack, @pokemon.defense, @pokemon.spatk, @pokemon.spdef, @pokemon.speed]
          @pokemon.exp += diffexp
          if i != destlevel
            @pokemon.calc_stats
            @battle.ui.level_up(self)
            message("#{self.name} grew to\nLV. #{i + 1}!", true, true, false)
            newstats = [@pokemon.totalhp, @pokemon.attack, @pokemon.defense, @pokemon.spatk, @pokemon.spdef, @pokemon.speed]
            @battle.ui.stats_up_window(self, oldstats, newstats)
          end
        end
      end
    end

    def faint
      @battle.ui.faint(self)
      message("#{self.name}\nfainted!", true, true)
      opposing_side.distribute_xp(self)
    end

    def attempt_to_escape(opponent)
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

    def end_of_turn

    end

    def lower_hp(damage)
      damage = damage.floor
      damage = @pokemon.hp if damage > @pokemon.hp
      return if damage <= 0
      @battle.ui.lower_hp(self, damage)
      @pokemon.hp -= damage
    end

    def get_stage(stat)
      if ![:attack, :defense, :spatk, :spdef, :speed, :accuracy, :evasion].include?(stat)
        raise "Invalid stat '#{stat}': must be one of [:attack, :defense, :spatk, :spdef, :speed, :accuracy, :evasion]"
      end
      return @stages.method(stat).call
    end

    def set_stage(stat, value)
      if ![:attack, :defense, :spatk, :spdef, :speed, :accuracy, :evasion].include?(stat)
        raise "Invalid stat '#{stat}': must be one of [:attack, :defense, :spatk, :spdef, :speed, :accuracy, :evasion]"
      end
      return @stages.method(stat.to_s + "=").call(value)
    end

    def lower_stat(stat, stages, animation = true, fail_message = true, success_message = true)
      current_stage = get_stage(stat)
      statname = {
        attack: "ATTACK",
        defense: "DEFENSE",
        spatk: "SPATK",
        spdef: "SPDEF",
        speed: "SPEED",
        accuracy: "ACCURACY",
        evasion: "EVASION"
      }[stat]
      if current_stage <= -6
        message("#{self.name}'s #{statname}\nwon't go any lower!") if fail_message
      else
        new_stage = current_stage - stages
        new_stage = -6 if new_stage < -6
        set_stage(stat, new_stage)
        diff = current_stage - new_stage
        if animation
          @battle.ui.stat_anim(self, :red, :down)
        end
        if success_message
          if diff == 1
            message("#{self.name}'s #{statname}\nfell!'")
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
