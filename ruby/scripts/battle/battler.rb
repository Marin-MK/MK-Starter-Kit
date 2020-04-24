class Battle
  class Battler
    attr_accessor :pokemon
    attr_accessor :effects
    attr_accessor :battle

    def initialize(pokemon)
      @pokemon = pokemon
      @effects = {}
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
