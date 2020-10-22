class Battle
  class Side
    attr_accessor :trainers
    attr_accessor :battlers
    attr_accessor :effects
    attr_accessor :index

    # Creates a new side of the battle.
    # @param battle [Battle] the battle associated with this side
    # @param arg [*] a trainer, Pokémon, or array thereof
    def initialize(battle, arg)
      validate battle => Battle
      @battle = battle
      # If arg is an array
      if arg.is_a?(Array)
        # Turn each element of arg into its own Trainer object.
        @trainers = arg.map do |e|
          next Trainer.new(battle, [e]) if e.is_a?(Pokemon)
          next Trainer.new(battle, e) if e.is_a?(Object::Trainer)
          e.battle = @battle if e.respond_to?(:battle=)
          next e
        end
      elsif arg.is_a?(Trainer)
        # If arg is already a Battle::Trainer, simply make that the only trainer of this side.
        arg.battle = @battle
        @trainers = [arg]
      elsif arg.is_a?(Object::Trainer)
        # If arg is a utility Trainer, wrap it in a Battle::Trainer.
        @trainers = [Trainer.new(battle, arg)]
      elsif arg.is_a?(Pokemon)
        # If arg is a Pokémon, wrap it in a Battle::Trainer.
        @trainers = [Trainer.new(battle, [arg])]
        @trainers[0].party[0].wild_pokemon = true
      else
        raise "Invalid argument for Side.new: #{arg.inspect}"
      end
      @effects = {}
      @trainers.each do |t|
        t.battle = @battle
        t.party.each { |b| b.battle = @battle }
      end
      @battlers = []
    end

    # Make the given battler one of the active battlers on this side.
    # @param battler [Battler] the battler to make active.
    def register_battler(battler)
      validate battler => Battler
      @battlers << battler
      battler.side = @index
      battler.index = @battlers.index(battler)
    end

    # Make the given battler no longer an active battler on this side.
    # @param battler [Battler] the battler to make inactive.
    def deregister_battler(battler)
      validate battler => Battler
      @battlers.delete(battler)
    end

    # Distribute exp over all battlers on this side that fought against the defeated battler.
    # @param defeated_battler [Battler] the battler that was defeated.
    def distribute_exp(defeated_battler)
      validate defeated_battler => Battler
      # TODO: only give exp for battlers that fought against the battler,
      #       instead of only to all currently active battlers, and factor it into
      #       the calculate_exp_gain method.
      @battlers.each do |battler|
        # Calculate the exp gain for each battler.
        exp = battler.calculate_exp_gain(defeated_battler)
        # Add the exp to the battler.
        battler.gain_exp(exp)
      end
    end
  end
end
