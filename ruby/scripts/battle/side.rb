class Battle
  class Side
    attr_accessor :trainers
    attr_accessor :battlers
    attr_accessor :effects

    def initialize(args)
      if args.is_a?(Array)
        @trainers = args.map do |e|
          next Trainer.new([e]) if e.is_a?(Pokemon)
          next Trainer.new(e) if e.is_a?(Object::Trainer)
          next e
        end
      elsif args.is_a?(Trainer)
        @trainers = [args]
      elsif args.is_a?(Object::Trainer)
        @trainers = [Trainer.new(args)]
      elsif args.is_a?(Pokemon)
        @trainers = [Trainer.new([args])]
      end
      @effects = {}
      @battlers = []
    end
  end
end
