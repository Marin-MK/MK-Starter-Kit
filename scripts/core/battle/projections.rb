class Battle
  class BattlerProjection
    # Used for identification only: don't use.
    attr_accessor :battler

    attr_accessor :species
    attr_accessor :moves
    attr_accessor :ability
    attr_accessor :item
    attr_accessor :hp

    def initialize(battler)
      @battler = battler
      @moves = []
      @species = battler.species # Species is known to the AI
      @hp = battler.hp # Exact HP is known to the AI
    end
  end
end

class Battle
  class BattleProjection
    attr_accessor :battlers
    attr_accessor :party
    attr_accessor :items

    def initialize
      @battlers = []
      @party = []
      @items = []
    end
  end
end
