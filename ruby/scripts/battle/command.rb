class Battle
  class Command
    attr_accessor :type
    attr_accessor :battler
    attr_accessor :argument

    def initialize(type, battler, argument)
      @type = type
      @battler = battler
      @argument = argument
    end

    def move
      return use_move? ? @argument : nil
    end

    def use_move?
      return @type == :use_move
    end
  end
end
