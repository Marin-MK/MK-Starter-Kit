class Battle
  attr_accessor :sides
  attr_accessor :effects
  attr_accessor :wild_pokemon
  attr_accessor :run_attempts
  attr_accessor :ui

  def initialize(side1, side2)
    @effects = {}
    @sides = [Side.new(self, side1), Side.new(self, side2)]
    @sides[0].index = 0
    @sides[1].index = 1
    @wild_battle = false
    if side2.is_a?(Pokemon)
      @sides[1].trainers[0].wild_pokemon = true
      @sides[1].register_battler(@sides[1].trainers[0].party[0])
      @wild_battle = true
    end
    @wild_pokemon = @sides[1].trainers[0].party[0] if @wild_battle
    @run_attempts = 1
    @stop = false
    @ai = AI.new(self)
    @ui = UI.new(self)
    @ui.begin_start
    @ui.shiny_sparkle if @wild_pokemon.shiny?
    @ui.finish_start("#{@wild_pokemon.name} appeared!")
    battler = @sides[0].trainers[0].party.find { |e| !e.egg? && !e.fainted? }
    @sides[0].register_battler(battler)
    @ui.send_out_initial_pokemon("Go! #{battler.name}!", battler)
    @ai.show_battler(battler)
    main
  end

  def wild_battle?
    return @wild_battle
  end

  def update
    @ui.update
  end

  def message(text, await_input = false, ending_arrow = false, reset = true)
    @ui.message(text, await_input, ending_arrow, reset)
  end

  def main
    @commands = []
    @turncount = 0
    loop do
      @turncount += 1
      for side in 0...@sides.size
        for battler in @sides[side].battlers
          if side == 0 # Player side
            cmd = get_player_command(battler)
            return if @stop
            @commands << cmd if !cmd.nil?
          else # Opposing side
            # Uses random move from moveset.
            cmd = get_opponent_command(battler)
            @commands << cmd if !cmd.nil?
          end
        end
      end
      sort_commands
      until @commands.empty?
        process_command(@commands[0])
        @commands.delete_at(0)
      end

      end_of_turn

      for side in 0...@sides.size
        if !@sides[side].battlers.any? { |b| !b.fainted? }
          if side == 0 # Black out
            raise "Black Out"
          else
            if @sides[side].trainers[0].wild_pokemon
              # Defeated a wild Pokémon
              @ui.fade_out
              @stop = true
              return
            end
          end
        end
      end
    end
  end

  # Sorts all commands (switching, using item, using move) based on
  # precedence, priority, speed, or randomness.
  # Can be used in the middle of a turn too.
  def sort_commands
    precedence = [:switch, :use_item, :use_move]
    # Sort commands based on priority, speed and command type
    @commands.sort! do |a, b|
      if a.type != b.type
        # Lower index => Go sooner (a, b)
        next precedence.index(a.type) <=> precedence.index(b.type)
      elsif a.type == :use_move
        if a.move.priority == b.move.priority
          # Equal priority => Use speed stat
          if a.battler.speed == b.battler.speed
            # Speed tie => Decide randomly
            next rand(2) == 0 ? 1 : -1
          else
            # Higher speed => Go sooner (b, a)
            next b.battler.speed <=> a.battler.speed
          end
        else
          # Higher priority => Go sooner (b, a)
          next b.move.priority <=> a.move.priority
        end
      else
        # Lower index => Go sooner (a, b)
        next @commands.index(a) <=> @commands.index(b)
      end
    end
  end

  def get_player_command(battler)
    loop do
      choice = @ui.choose_command(battler)
      if choice.fight?
        cmd = get_move_command(battler)
        next if cmd.nil?
        return cmd
      elsif choice.bag?

      elsif choice.pokemon?
        newbattler = @ui.switch_battler(battler)
        next if battler.nil? # Go back to @ui.choose_command
        return Command.new(:switch, battler, newbattler)
      elsif choice.run?
        if wild_battle?
          escaped = battler.attempt_to_escape(@sides[1].battlers[0])
          if escaped
            @ui.fade_out
            @stop = true
            return
          end
        else
          message("No! There's no running\nfrom a TRAINER battle!", true, true)
        end
      end
      break
    end
  end

  def get_move_command(battler)
    movechoice = nil
    move = nil
    index = nil
    loop do
      movechoice = @ui.choose_move(battler, index)
      break if movechoice.cancel? # Break out of move choosing loop
      move = battler.moves[movechoice.value]
      if move.pp <= 0
        message("There's no PP left for\nthis move!", true, true)
        index = movechoice.value
        next # Go back to @ui.choose_move
      end
      break
    end
    return if movechoice.cancel? # Go back to @ui.choose_command
    return Command.new(:use_move, battler, move)
  end

  def get_opponent_command(battler)
    move, target = @ai.pick_move_and_target(battler)
    target = @sides[0].battlers.find { |b| b == target.battler }
    return Command.new(:use_move, battler, move, target)
  end

  def process_command(command)
    if command.use_move?
      return if command.battler.fainted?
      move = BaseMove.new(self, command.move)
      move.execute(command.battler, command.target)
    elsif command.switch_pokemon?
      @ui.recall_battler("#{command.battler.name}, that's enough!\nCome back!", command.battler)
      @ui.send_out_pokemon("Go! #{command.new_battler.name}!", command.new_battler)
    else
      raise "not yet implemented"
    end
  end

  def end_of_turn
    for side in 0...@sides.size
      for battler in @sides[side].battlers
        battler.end_of_turn
      end
    end
  end
end
