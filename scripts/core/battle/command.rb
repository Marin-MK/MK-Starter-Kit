class Battle
  class Command
    attr_accessor :type
    attr_accessor :battler
    attr_accessor :argument

    # Create a new Command object. Reused for various purposes.
    # @param type [Symbol] the type of command. Used to identify different uses of the Command object.
    # @param battler [Battler] the battler the command is associated with, if any.
    # @param *arguments [*] any arguments for the desired purpose.
    def initialize(type, battler, *arguments)
      validate \
          type => Symbol,
          battler => Battler
      @type = type
      @battler = battler
      @arguments = arguments
    end

    #===================== Using Move =====================#
    # @return [Boolean] whether the command type is that of using a move.
    def use_move?
      return @type == :use_move
    end

    # @return [MoveObject] the move object the battler wants to use.
    def move
      return use_move? ? @arguments[0] : nil
    end

    # @return [Battler] the target of the move.
    def target
      return use_move? ? @arguments[1] : nil
    end

    #===================== Switching Pokémon =====================#
    # @return [Boolean] whether the command type is that of switching a Pokémon.
    def switch_pokemon?
      return @type == :switch
    end

    # @return [Battler] the new battler to send out.
    def new_battler
      return switch_pokemon? ? @arguments[0] : nil
    end

    #====================== Running =======================#
    # @return [Boolean] whether the command type is that of running away.
    def run?
      return @type == :run
    end

    # @return [Battler] the battle opposite the running battler.
    def opposing_battler
      return run? ? @arguments[0] : nil
    end
  end
end
