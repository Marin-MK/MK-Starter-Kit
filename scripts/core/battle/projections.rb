class Battle
  class BattleProjection
    attr_accessor :sides

    # Creates a new battle projection.
    def initialize
      @sides = [SideProjection.new, SideProjection.new]
    end
  end
end

class Battle
  class SideProjection
    attr_accessor :battlers
    attr_accessor :party

    # Creates a new battle side projection.
    def initialize
      @battlers = []
      @party = []
    end
  end
end

class Battle
  class BattlerProjection
    # Used for identification only: don't use.
    attr_accessor :battler

    attr_accessor :species
    attr_accessor :moves
    attr_accessor :ability
    attr_accessor :item
    attr_accessor :hp

    # Creates a new battler projection.
    # @param battler [Battler] the battler to project.
    def initialize(battler)
      validate battler => Battler
      @battler = battler
      @moves = []
      @species = battler.species # Species is known to the AI
      @hp = battler.hp # Exact HP is known to the AI
    end
  end
end
