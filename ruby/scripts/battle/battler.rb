class Battle
  BattleStats = Struct.new(:attack, :defense, :spatk, :spdef, :speed, :accuracy, :evasion)

  class Battler
    attr_accessor :pokemon
    attr_accessor :effects
    attr_accessor :battle
    attr_accessor :stages

    def initialize(pokemon)
      @pokemon = pokemon
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

    def level
      return @pokemon.level
    end

    def species
      return @pokemon.species
    end

    def moves
      return @pokemon.moves
    end

    def name
      return @pokemon.name
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
      return (base_attack * GENERIC_STAGE_MULTIPLIER[@stages.spdef + 6]).floor
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

    def message(msg)
      @battle.message(msg)
    end

    def attempt_to_escape(opponent)
      a = @pokemon.speed
      b = [1, opponent.pokemon.speed].max
      c = @battle.run_attempts
      chance = (a * 28.0) / b + 30 * c
      @battle.run_attempts += 1
      if rand(0..255) < chance
        message("Got away safely!")
        return true
      else
        message("Can't escape!")
        return false
      end
    end
  end
end
