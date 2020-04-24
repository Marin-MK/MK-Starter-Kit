class Battle
  class Trainer
    attr_accessor :name
    attr_accessor :party
    attr_accessor :items
    attr_accessor :skill
    attr_accessor :wild_pokemon
    attr_accessor :battle

    def initialize(party = [])
      party = party.party if party.is_a?(Object::Trainer)
      @party = party.map { |e| Battler.new(e) }
    end
  end
end
