class Battle
  attr_accessor :sides
  attr_accessor :effects
  attr_accessor :wild_pokemon
  attr_accessor :run_attempts

  def initialize(side1, side2)
    @effects = {}
    @sides = [Side.new(self, side1), Side.new(self, side2)]
    @wild_battle = false
    if side2.is_a?(Pokemon)
      @sides[1].trainers[0].wild_pokemon = true
      @sides[1].battlers = [@sides[1].trainers[0].party[0]]
      @wild_battle = true
    end
    @wild_pokemon = @sides[1].trainers[0].party[0] if @wild_battle
    @run_attempts = 1
    @ui = UI.new(self)
    @ui.begin_start
    @ui.shiny_sparkle if @wild_pokemon.shiny?
    @ui.finish_start("Wild #{@wild_pokemon.pokemon.species.name} appeared!")
    battler = @sides[0].trainers[0].party.find { |e| !e.egg? && !e.fainted? }
    @sides[0].battlers << battler
    @ui.send_out_initial_pokemon("Go! #{battler.name}!", battler)
    main
  end

  def wild_battle?
    return @wild_battle
  end

  def update
    @ui.update
  end

  def message(text)
    @ui.message(text)
  end

  def main
    loop do
      for side in 0...@sides.size
        for battler in @sides[side].battlers
          if side == 0 # Player side
            loop do
              choice = @ui.choose_command(battler)
              if choice.fight?
                movechoice = @ui.choose_move(battler)
                next if movechoice.cancel?
                move = battler.moves[movechoice.value]
                p "#{battler.name} used #{move.name}!"
              elsif choice.bag?

              elsif choice.pokemon?

              elsif choice.run?
                if wild_battle?
                  escaped = battler.attempt_to_escape(@sides[1].battlers[0])
                  if escaped
                    @ui.fade_out
                    return
                  end
                else
                  message("No! There's no running\nfrom a TRAINER battle!")
                end
              end
              break
            end
          else # Opposing side

          end
        end
      end
    end
  end
end
