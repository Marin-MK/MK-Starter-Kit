class Battle
  class Side
    attr_accessor :trainers
    attr_accessor :battlers
    attr_accessor :effects

    def initialize(battle, arg)
      @battle = battle
      if arg.is_a?(Array)
        @trainers = arg.map do |e|
          next Trainer.new([e]) if e.is_a?(Pokemon)
          next Trainer.new(e) if e.is_a?(Object::Trainer)
          next e
        end
      elsif arg.is_a?(Trainer)
        @trainers = [arg]
      elsif arg.is_a?(Object::Trainer)
        @trainers = [Trainer.new(arg)]
      elsif arg.is_a?(Pokemon)
        @trainers = [Trainer.new([arg])]
      end
      @effects = {}
      @trainers.each do |t|
        t.battle = @battle
        t.party.each { |b| b.battle = @battle }
      end
      @battlers = []
    end
  end
end
