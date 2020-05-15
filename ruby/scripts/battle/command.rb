class Battle
  class Command
    attr_accessor :type
    attr_accessor :battler
    attr_accessor :argument

    def initialize(type, battler, *arguments)
      @type = type
      @battler = battler
      @arguments = arguments
    end

    #===================== Using Move =====================#
    def use_move?
      return @type == :use_move
    end

    def move
      return use_move? ? @arguments[0] : nil
    end

    def target
      return use_move? ? @arguments[1] : nil
    end

    #===================== Switching Pokémon =====================#
    def switch_pokemon?
      return @type == :switch
    end

    def new_battler
      return @arguments[0]
    end
  end
end
