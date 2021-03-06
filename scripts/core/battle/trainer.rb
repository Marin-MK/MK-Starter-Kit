class Battle
  class Trainer
    attr_accessor :battle
    attr_accessor :name
    attr_accessor :party
    attr_accessor :items
    attr_accessor :skill
    attr_accessor :battle

    # Creates a Trainer object to wrap a utility trainer.
    # @param battle [Battle] the battle associated with this trainer
    # @param party [Object::Trainer, Array<Pokemon>] a trainer and its party or a list of Pokémon
    def initialize(battle, party = [])
      validate \
          battle => Battle,
          party => [Object::Trainer, Array]
      validate_array party => Pokemon if party.is_a?(Array)
      @battle = battle
      trainer = party if party.is_a?(Object::Trainer)
      party = trainer.party if trainer
      @party = party.map { |e| Battler.new(battle, e) }
      @name = trainer.name if trainer
    end
  end
end
