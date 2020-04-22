class Battle
  class Trainer
    attr_accessor :name
    attr_accessor :party
    attr_accessor :items
    attr_accessor :skill
    attr_accessor :wild_pokemon

    def initialize(party = [])
      @party = party.map { |e| Battler.new(e) }
      @wild_pokemon = true
    end
  end
end
