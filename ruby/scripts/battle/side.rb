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
        exp = exp.floor
        exp = 104
        battler.gain_exp(exp)
      end
    end
  end
end
