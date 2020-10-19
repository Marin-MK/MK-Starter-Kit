class Battle
  attr_accessor :sides
  attr_accessor :effects
  attr_accessor :wild_pokemon
  attr_accessor :run_attempts
  attr_accessor :ui

  # Initializes a battle between two different sides.
  # @param side1 [*] a trainer, Pokémon, or array thereof
  # @param side2 [*] a trainer, Pokémon, or array thereof
  def initialize(side1, side2)
    # Initialize the hash containing all global battle effects.
    @effects = {}
    # Convert and process the two sides of the battle.
    @sides = [Side.new(self, side1), Side.new(self, side2)]
    @sides[0].index = 0
    @sides[1].index = 1
    @wild_battle = false
    # Hardcode the battle to be a wild battle if the second side is one Pokémon object
    if side2.is_a?(Pokemon)
      @sides[1].trainers[0].wild_pokemon = true
      @sides[1].register_battler(@sides[1].trainers[0].party[0])
      @wild_battle = true
    end
    @wild_pokemon = @sides[1].trainers[0].party[0] if @wild_battle
    @run_attempts = 1
    @stop = false
    # Define a helper AI object that manages the opposing side.
    @ai = AI.new(self)
    # Define a helper UI object that manages all visuals
    @ui = UI.new(self)
    # Start initializing the UI
    @ui.begin_start
    # Shiny sparkle if we're encoutering a shiny wild Pokémon
    @ui.shiny_sparkle if @wild_pokemon.shiny?
    # Show our encounter message
    @ui.finish_start("#{@wild_pokemon.name} appeared!")
    # Find the first able battler of our party
    battler = @sides[0].trainers[0].party.find { |e| !e.egg? && !e.fainted? }
    # Register the battler as active on our side
    @sides[0].register_battler(battler)
    # Send out our battler
    @ui.send_out_initial_pokemon("Go! #{battler.name}!", battler)
    # Show our battler and its visible properties to our AI handler
    @ai.show_battler(battler)
    # Start the main process
    main
  end

  # @return [Boolean] whether or not this battle is a battle against a wild Pokémon.
  def wild_battle?
    return @wild_battle
  end

  # Updates the battle visuals.
  def update
    @ui.update
  end

  # Shows a text message.
  # @param text [String] the text to display.
  # @param await_input [Boolean] whether to end the message without needing input.
  # @param ending_arrow [Boolean] whether the message should have a moving down arrow.
  # @param reset [Boolean] whether the message box should clear after the message is done.
  def message(text, await_input = false, ending_arrow = false, reset = true)
    @ui.message(text, await_input, ending_arrow, reset)
  end

  # The main battle processing method.
  def main
    @commands = []
    @turncount = 0
    loop do
      @turncount += 1
      # Iterate through all sides of the battle (2, normally)
      for side in 0...@sides.size
        # Iterate through all active battlers on each side
        for battler in @sides[side].battlers
          # If the battler is on the player's side, get the player's command
          if side == 0 # Player side
            cmd = get_player_command(battler)
            return if @stop
            @commands << cmd if !cmd.nil?
          else # If the battler is on the opponent's side, get its command.
            # Use random move from moveset.
            cmd = get_opponent_command(battler)
            @commands << cmd if !cmd.nil?
          end
        end
      end
      # Sort all the commands based on priority (i.e. switching, items, priority moves)
      sort_commands
      # Process each command one by one until all commands have been processed
      until @commands.empty?
        # Process the command
        process_command(@commands[0])
        # Remove it from the list
        @commands.delete_at(0)
      end

      # Process end-of-turn effects
      end_of_turn

      # Temporary logic to allow battles to end - to be removed
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
    # The hard-coded precendence of different command types.
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

  # Gets the player's command for one of their battlers.
  # @param battler [Battler] the battler that is to use a move.
  # @return [Command] the player's command for the battler.
  def get_player_command(battler)
    # Loop the choose command menu until a command was actually chosen
    loop do
      # Get the main choice
      choice = @ui.choose_command(battler)
      if choice.fight?
        # If the player chooses Fight, get the move the battler should use
        cmd = get_move_command(battler)
        next if cmd.nil?
        return cmd
      elsif choice.bag?
        # If the player chooses Bag, get which item to use and pick the Pokémon
      elsif choice.pokemon?
        # If the player chooses Pokémon, get which Pokémon to switch in.
        newbattler = @ui.switch_battler(battler)
        next if battler.nil? # Go back to @ui.choose_command
        return Command.new(:switch, battler, newbattler)
      elsif choice.run?
        # If the player chooses Run, try to escape from the battle.
        if wild_battle?
          escaped = battler.attempt_to_escape(@sides[1].battlers[0])
          if escaped
            @ui.fade_out
            @stop = true
            return
          end
        else
          # Cannot run from non-wild battles
          message("No! There's no running\nfrom a TRAINER battle!", true, true)
        end
      end
      break
    end
  end

  # Gets which move the battler should use.
  # @param battler [Battler] the battler that is to use a move.
  # @return [Command] the move the battler will use.
  def get_move_command(battler)
    movechoice = nil
    move = nil
    index = 0
    # Loop the move choice UI, in case a move can't be used.
    loop do
      # Choose the move to use
      movechoice = @ui.choose_move(battler, index)
      break if movechoice.cancel? # Break out of move choosing loop
      move = battler.moves[movechoice.value]
      # Cannot use the move if it has no PP
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

  # Gets the opponent's command for one of their battlers.
  # @param battler [Battler] the battler that is to use a move.
  # @return [Command] the opponent's command for the battler.
  def get_opponent_command(battler)
    move, target = @ai.pick_move_and_target(battler)
    target = @sides[0].battlers.find { |b| b == target.battler }
    return Command.new(:use_move, battler, move, target)
  end

  # Processes and executes a battle command.
  # @param command [Command] a fight, item or switch command.
  def process_command(command)
    if command.use_move?
      # If the command is a fight command
      # Don't use the move if the battler is fainted
      return if command.battler.fainted?
      # Associate a helper BaseMove class with the move data
      move = BaseMove.new(self, command.move)
      # Execute the move
      move.execute(command.battler, command.target)
    elsif command.switch_pokemon?
      # If the command is a switch command, recall the active battler
      @ui.recall_battler("#{command.battler.name}, that's enough!\nCome back!", command.battler)
      # Send out the new battler
      @ui.send_out_pokemon("Go! #{command.new_battler.name}!", command.new_battler)
    else
      raise "not yet implemented"
    end
  end

  # Process effects that happen at the end of a turn.
  def end_of_turn
    for side in 0...@sides.size
      for battler in @sides[side].battlers
        battler.end_of_turn
      end
    end
  end
end
