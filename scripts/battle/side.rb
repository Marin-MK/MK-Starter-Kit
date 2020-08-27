class Battle
  class Side
    attr_accessor :trainers
    attr_accessor :battlers
    attr_accessor :effects
    attr_accessor :index

    def initialize(battle, arg)
      @battle = battle
      if arg.is_a?(Array)
        @trainers = arg.map do |e|
          next Trainer.new(battle, [e]) if e.is_a?(Pokemon)
          next Trainer.new(battle, e) if e.is_a?(Object::Trainer)
          e.battle = @battle if e.respond_to?(:battle=)
          next e
        end
      elsif arg.is_a?(Trainer)
        arg.battle = @battle
        @trainers = [arg]
      elsif arg.is_a?(Object::Trainer)
        @trainers = [Trainer.new(battle, arg)]
      elsif arg.is_a?(Pokemon)
        @trainers = [Trainer.new(battle, [arg])]
        @trainers[0].party[0].wild_pokemon = true
      end
      @effects = {}
      @trainers.each do |t|
        t.battle = @battle
        t.party.each { |b| b.battle = @battle }
      end
      @battlers = []
    end

    def register_battler(battler)
      @battlers << battler
      battler.side = @index
      battler.index = @battlers.index(battler)
    end

    def distribute_xp(defeated_battler)
      @battlers.each do |battler|
        exp = battler.calculate_exp_gain(defeated_battler)
        battler.gain_exp(exp)
      end
    end
  end
end
