class Battle
  attr_accessor :sides
  attr_accessor :effects
  attr_accessor :wild_pokemon

  def initialize(side1, side2)
    @effects = {}
    @sides = [Side.new(side1), Side.new(side2)]
    @wild_battle = false
    if side2.is_a?(Pokemon)
      @sides[1].trainers[0].wild_pokemon = true
      @wild_battle = true
    end
    @wild_pokemon = @sides[1].trainers[0].party[0] if @wild_battle
    @ui = UI.new(self)
    @ui.begin_start
    @ui.shiny_sparkle if @wild_pokemon.shiny?
    @ui.finish_start("Wild #{@wild_pokemon.pokemon.species.name} appeared!")
    pokemon = @sides[0].trainers[0].party.find { |e| !e.egg? && !e.fainted? }
    @ui.send_out_initial_pokemon("Go! #{pokemon.name}!", pokemon)
    main
  end

  def wild_battle?
    return @wild_battle
  end

  def update
    @ui.update
  end

  def main
    loop do
      for side in @sides
        for battler in side.battlers
          if side == 0 # Player side
            choice = @ui.choose_command(battler)
            if choice.fight?

            elsif choice.bag?

            elsif choice.pokemon?

            elsif choice.run?
              
            end
          else # Opposing side

          end
        end
      end
    end
  end
end
