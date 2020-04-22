class Battle
  attr_accessor :sides
  attr_accessor :effects
  attr_accessor :wild_pokemon

  def initialize(side1, side2)
    @effects = {}
    @sides = [Side.new(side1), Side.new(side2)]
    @wild_battle = side2.is_a?(Pokemon)
    @wild_pokemon = @sides[1].trainers[0].party[0] if @wild_battle
    @ui = UI.new(self)
    @ui.begin_start
    @ui.shiny_sparkle if @wild_pokemon.shiny?
    @ui.finish_start("Wild #{@wild_pokemon.pokemon.species.name} appeared!")
    main
  end

  def wild_battle?
    return @wild_battle
  end

  def main
    loop do
      @ui.update
    end
  end
end
