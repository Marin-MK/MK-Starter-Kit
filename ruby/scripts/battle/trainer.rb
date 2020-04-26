class Battle
  class Trainer
    attr_accessor :battle
    attr_accessor :name
    attr_accessor :party
    attr_accessor :items
    attr_accessor :skill
    attr_accessor :wild_pokemon
    attr_accessor :battle

    def initialize(battle, party = [])
      @battle = battle
      party = party.party if party.is_a?(Object::Trainer)
      @party = party.map { |e| Battler.new(battle, e) }
    end
  end
end
