class Battle
  class UI
    attr_accessor :viewport
    attr_accessor :sprites

    # Initializes the visuals of a battle.
    # @param battle [Battle] the battle associated with this UI.
    def initialize(battle)
      validate battle => Battle
      @battle = battle
      # Start and process a transition.
      transition = Transition.new
      transition.main
      transition.dispose
      # Create the global viewport used for (almost) all UI elements.
      @viewport = Viewport.new(0, 0, System.width, System.height)
      @viewport.z = 99997
      @sprites = {}
      # Top half of the black bars during the intro.
      @sprites["blackbg1"] = Sprite.new(@viewport)
      @sprites["blackbg1"].bitmap = Bitmap.new(System.width, System.height / 2)
      @sprites["blackbg1"].bitmap.fill_rect(0, 0, System.width, System.height / 2, Color.new(0, 0, 0))
      @sprites["blackbg1"].z = 999999
      # Bottom half of the black bars during the intro.
      @sprites["blackbg2"] = Sprite.new(@viewport)
      @sprites["blackbg2"].bitmap = Bitmap.new(System.width, System.height / 2)
      @sprites["blackbg2"].bitmap.fill_rect(0, 0, System.width, System.height / 2, Color.new(0, 0, 0))
      @sprites["blackbg2"].y = @sprites["blackbg1"].bitmap.height
      @sprites["blackbg2"].z = 999999
      # The battle background.
      @sprites["bg"] = Sprite.new(@viewport)
      @sprites["bg"].bitmap = Bitmap.new("gfx/ui/battle/backdrops/standard")
      @sprites["bg"].z = -2
      # The player's battle base.
      @sprites["base1"] = BattleBase.new(@viewport)
      @sprites["base1"].x = System.width + 256
      @sprites["base1"].y = 194
      @sprites["base1"].z = -1
      # The opponent's battle base.
      @sprites["base2"] = BattleBase.new(@viewport, true)
      @sprites["base2"].x = -@sprites["base2"].bitmap.width - 256
      @sprites["base2"].y = 92
      @sprites["base2"].z = -1
      # The player's trainer sprite.
      @sprites["trainer1"] = TrainerSprite.new(0, @viewport)
      @sprites["trainer1"].x = System.width + 256
      @sprites["trainer1"].y = 126
      @sprites["trainer1"].z = 1
      if @battle.wild_battle?
        # The wild Pokémon's sprite.
        @sprites["pokemon2"] = BattlerSprite.new(@battle.wild_pokemon, true, @viewport)
        @sprites["pokemon2"].color = Color.new(0, 0, 0, 128)
        @sprites["pokemon2"].x = @sprites["base2"].x + 64 + @battle.wild_pokemon.pokemon.species.battler_front_x
        @sprites["pokemon2"].y = 44 + @battle.wild_pokemon.pokemon.species.battler_front_y
      end
      # The tall grass overlay that scrolls during the intro.
      @sprites["grass"] = Sprite.new(@viewport)
      @sprites["grass"].bitmap = Bitmap.new("gfx/ui/battle/backdrops/standard_grass")
      @sprites["grass"].y = 130
      @sprites["grass"].z = 2
      # Initialize the message window used for all communication.
      @msgwin = MessageWindow.new(
        y: 224,
        z: 3,
        viewport: @viewport,
        width: System.width,
        height: 96,
        text: "",
        letter_by_letter: false,
        color: Color::LIGHTBASE,
        shadow_color: Color.new(104, 88, 112),
        windowskin: :battle
      )
      # Records the last selected move
      @last_move_index = 0
    end

    # Disposes all sprites associated with this UI.
    def dispose
      @sprites.each_value { |e| e.dispose if !e.disposed? }
      @msgwin.dispose
      @viewport.dispose
    end

    # Waits a certain number of seconds.
    # @param seconds [Float] the number of seconds to wait.
    def wait(seconds)
      validate seconds => Float
      for i in 1..framecount(seconds)
        update
      end
    end

    # Updates the visuals and animates where necessary.
    def update(update_main = true)
      validate update_main => Boolean
      if update_main
        System.update
      end
      @sprites["base1"].update
      @sprites["base2"].update
      @sprites["trainer1"].update
      @sprites["pokemon1"].update if @sprites["pokemon1"]
      @sprites["databox1"].update if @sprites["databox1"]
      @sprites["pokemon2"].update if @sprites["pokemon2"]
      @sprites["databox2"].update if @sprites["databox2"]
      @sprites["ball"].update if @sprites["ball"] && !@sprites["ball"].disposed?
      @msgwin.update
      @ball_animation.update if @ball_animation
    end

    # Starts the first part of the battle intro.
    def begin_start
      wait(0.2)
      frames = framecount(0.8)
      for i in 1..frames
        update
        # Move the black bars vertically out of screen, split from the middle.
        @sprites["blackbg1"].y -= System.height / 2.0 / frames
        @sprites["blackbg2"].y += System.height / 2.0 / frames
        # Move the battle bases, battlers and trainers horizontally.
        @sprites["grass"].x -= 480.0 / frames
        @sprites["base1"].x -= 364.0 / frames
        @sprites["base2"].x += 368.0 / frames
        @sprites["trainer1"].x = @sprites["base1"].x + 100
        @sprites["pokemon2"].x = @sprites["base2"].x + 64 + @sprites["pokemon2"].pokemon.species.battler_front_x
      end
      @sprites["blackbg1"].dispose
      @sprites["blackbg2"].dispose
      frames = framecount(0.8)
      for i in 1..frames
        update
        # Move the battle bases, battlers and trainers horizontally.
        @sprites["grass"].x -= 480.0 / frames
        @sprites["grass"].y += 144.0 / frames
        @sprites["base1"].x -= 364.0 / frames
        @sprites["base2"].x += 368.0 / frames
        @sprites["trainer1"].x = @sprites["base1"].x + 100
        @sprites["pokemon2"].x = @sprites["base2"].x + 64 + @sprites["pokemon2"].pokemon.species.battler_front_x
      end
      # Dispose the grass overlay as it is not used anymore.
      @sprites["grass"].dispose
    end

    # Finishes by running the second part of the battle intro.
    # @param intro_message [String] the encounter message to display.
    def finish_start(intro_message)
      validate intro_message => String
      @msgwin.letter_by_letter = true
      @msgwin.ending_arrow = true
      @msgwin.text = intro_message
      # Create the databox for the opposing Pokémon
      @sprites["databox2"] = Databox.new(@battle.wild_pokemon, true)
      @sprites["databox2"].x = -@sprites["databox2"].width
      @sprites["databox2"].y = 32
      frames = framecount(0.4)
      for i in 1..frames
        update
        # Move the opposing Pokémon's databox to the right place
        @sprites["databox2"].x += 226.0 / frames
        # Remove the white overlay from the Pokémon sprite
        @sprites["pokemon2"].color.alpha -= 128.0 / frames if @sprites["pokemon2"].color.alpha > 0
      end
      update while @msgwin.running?
      @msgwin.text = ""
      @msgwin.ending_arrow = false
    end

    # Show the initial battler being sent out
    # @param message [String] the sendout message for the battler.
    # @param battler [Battler] the battler to be sent out.
    def send_out_initial_pokemon(message, battler)
      validate \
          message => String,
          battler => Battler
      message(message, false)
      frames = framecount(0.5)
      # Show the first frame of the trainer throwing a ball.
      @sprites["trainer1"].frame = 1
      for i in 1..frames
        update
        # Move the trainer out of screen
        @sprites["trainer1"].x -= 236.0 / frames
        if i >= framecount(0.1) && @sprites["trainer1"].frame == 1 ||
           i >= framecount(0.2) && @sprites["trainer1"].frame == 2 ||
           i >= framecount(0.3) && @sprites["trainer1"].frame == 3
          # Go to the next frame in the trainer ball throw animation.
          @sprites["trainer1"].frame += 1
          if @sprites["trainer1"].frame == 4
            # Throw the ball itself
            throw_ball(battler)
          end
        end
      end
      update until @sprites["ball"].almost_done?
      # Show the sendout animation for the battler.
      send_out_pokemon(nil, battler, false)
    end

    # Shows the ball throw animation for sending out a battler.
    # @param battler [Battler] the battler to send out.
    def throw_ball(battler)
      validate battler => Battler
      @sprites["ball"] = BallSprite.new(battler.ball_used, @viewport)
      @sprites["ball"].update
    end

    # Shows the sendout animation for the battler.
    # @param msg [NilClass, String] the message to display upon sendout.
    # @param battler [Battler] the battler to send out.
    # @param throw [Boolean] whether to show the ball throw animation.
    def send_out_pokemon(msg, battler, throw = true)
      validate \
          msg => [NilClass, String],
          battler => Battler,
          throw => Boolean
      if msg
        message(msg, false)
      end
      if throw
        throw_ball(battler)
        update until @sprites["ball"].almost_done?
      end
      # Create a new battler sprite for the Pokémon
      @sprites["pokemon1"] = BattlerSprite.new(battler, false, @viewport)
      @sprites["pokemon1"].x = 80 + battler.pokemon.species.battler_back_x
      @sprites["pokemon1"].y = 226 - @sprites["pokemon1"].src_rect.height + battler.pokemon.species.battler_back_y
      @sprites["pokemon1"].color = Color.new(248, 176, 240)
      @sprites["pokemon1"].appear_from_ball(0.4)
      # Show a white screen flash
      @sprites["white"] = Sprite.new(@viewport)
      @sprites["white"].bitmap = Bitmap.new(System.width, System.height)
      @sprites["white"].bitmap.fill_rect(0, 0, System.width, System.height, Color.new(248, 248, 248))
      @sprites["white"].opacity = 0
      wait(0.1)
      frames = framecount(0.15)
      for i in 1..frames
        update
        @sprites["white"].opacity += 255.0 / framecount(0.25)
      end
      # Show the fragmentation animation when the ball opens
      @ball_animation = BallOpenAnimation.new(@sprites["pokemon1"], @viewport)
      frames = framecount(0.1)
      for i in 1..frames
        update
        @sprites["white"].opacity += 255.0 / framecount(0.25)
      end
      # Create a new databox for the Pokémon
      @sprites["databox1"] = Databox.new(battler, false)
      @sprites["databox1"].x = System.width
      @sprites["databox1"].y = 148
      frames = framecount(0.2)
      for i in 1..frames
        update
        # Remove the flash overlays and white colors.
        @sprites["pokemon1"].color.alpha -= 255.0 / frames
        @sprites["white"].opacity -= 255.0 / frames
        @sprites["databox1"].x -= 228.0 / frames
      end
      @sprites["white"].dispose
      @sprites.delete("white")
    end

    # Fade out and stop the UI.
    def fade_out
      vp = Viewport.new(0, 0, System.width, System.height)
      vp.z = 999999
      # Create an overlay sprite and bitmap.
      blackbg = Sprite.new(vp)
      blackbg.bitmap = Bitmap.new(System.width, System.height)
      blackbg.bitmap.fill_rect(0, 0, System.width, System.height, Color.new(0, 0, 0))
      blackbg.opacity = 0
      blackbg.z = 999999
      frames = framecount(0.6)
      # Fade the background in
      for i in 1..frames
        update
        blackbg.opacity += 255.0 / frames
      end
      # Dispose all the UI components
      dispose
      # Wait 0.2 seconds
      for i in 1..framecount(0.2)
        System.update
      end
      # Fade the background out
      for i in 1..frames
        System.update
        blackbg.opacity -= 255.0 / frames
      end
      blackbg.dispose
      vp.dispose
    end

    # Gets and returns a battle command to the battle logic.
    # @param battler [Battler] the battler that is to choose a command.
    # @return [Command] the command for the battler.
    def choose_command(battler)
      validate battler => Battler
      @msgwin.text = "What will\n#{battler.name} do?"
      @msgwin.letter_by_letter = false
      # Shows a 2x2 choice window.
      @cmdwin = MultiChoiceWindow.new(
        x: 240,
        y: 224,
        z: 4,
        width: 240,
        height: 96,
        line_x_space: 112,
        viewport: @viewport,
        choices: [["FIGHT", "BAG"], ["POKéMON", "RUN"]],
        cancel_choice: nil,
        arrow_path: "gfx/ui/battle/choice_arrow",
        arrow_states: 1,
        can_loop: false,
        color: Color.new(72, 72, 72),
        windowskin: :battle_choice
      )
      cmd = nil
      loop do
        update
        cmd = @cmdwin.update
        if !cmd.nil?
          cmd = Choice.new(cmd)
          break
        end
      end
      @cmdwin.dispose
      return cmd
    end

    # Gets and returns a move choice to the battle logic.
    # @param battler [Battler] the battler that is to use a move.
    # @param initial_index [Integer] the move index that begins selected.
    # @return [Choice] the move choice of the battler.
    def choose_move(battler, initial_index = @last_move_index)
      validate \
          battler => Battler,
          initial_index => Integer
      choices = [["-", "-"], ["-", "-"]]
      for i in 0...battler.moves.size
        choices[i / 2][i % 2] = battler.moves[i].name
      end
      # Creates a new 2x2 choice window for the moves.
      @cmdwin = MultiChoiceWindow.new(
        x: 0,
        y: 224,
        z: 4,
        width: 320,
        height: 96,
        line_x_space: 144,
        viewport: @viewport,
        initial_choice: initial_index,
        choices: choices,
        arrow_path: "gfx/ui/battle/choice_arrow",
        arrow_states: 1,
        can_loop: false,
        color: Color.new(72, 72, 72),
        windowskin: :battle_choice,
        line_y_start: -2,
        small: true
      )
      # Creates an extra window for PP and type display
      @ppwin = BaseWindow.new(160, 96, :battle_choice, @viewport)
      @ppwin.x = 320
      @ppwin.y = 224
      @ppwin.z = 4
      # Draw the initial move's information to the PP window.
      draw_move_info(battler, initial_index)
      cmd = nil
      loop do
        update
        oldidx = @cmdwin.index
        cmd = @cmdwin.update(false)
        if choices[@cmdwin.index / 2][@cmdwin.index % 2] == "-"
          # Empty move slot
          @cmdwin.set_index(oldidx, false)
        end
        if oldidx != @cmdwin.index
          # Draw the selected move's information to the PP window
          draw_move_info(battler, @cmdwin.index)
          Audio.se_play("audio/se/menu_select")
        end
        if !cmd.nil?
          cmd = Choice.new(cmd)
          break
        end
      end
      @cmdwin.dispose
      @ppwin.dispose
      @last_move_index = cmd if !cmd.cancel?
      return cmd
    end

    # Draws the PP and type of a certain battler's move.
    # @param battler [Battler] the battler of which the move is.
    # @param move_index [Integer] the move index to draw the information of.
    def draw_move_info(battler, move_index)
      validate \
          battler => Battler,
          move_index => Integer
      pp_base = Color.new(32, 32, 32)
      pp_shadow = Color.new(208, 208, 200)
      # The fraction of PP left.
      fraction = battler.moves[move_index].pp / battler.moves[move_index].totalpp.to_f
      if fraction == 0
        # Out of PP
        pp_base = Color.new(232, 0, 0)
        pp_shadow = Color.new(240, 216, 152)
      elsif fraction < 0.25
        # Less than a quarter PP
        pp_base = Color.new(248, 144, 0)
        pp_shadow = Color.new(248, 232, 112)
      elsif fraction < 0.5
        # Less than half PP
        pp_base = Color.new(232, 216, 0)
        pp_shadow = Color.new(248, 240, 136)
      end
      @ppwin.clear
      # Draw the PP and the total PP.
      @ppwin.draw_text(
        x: 16,
        y: 22,
        text: "PP",
        color: pp_base,
        shadow_color: pp_shadow,
        small: true
      )
      @ppwin.draw_text(
        x: 120,
        y: 26,
        text: battler.moves[move_index].pp.to_s + "/",
        align: :right,
        color: pp_base,
        shadow_color: pp_shadow
      )
      @ppwin.draw_text(
        x: 144,
        y: 26,
        text: battler.moves[move_index].totalpp.to_s,
        align: :right,
        color: pp_base,
        shadow_color: pp_shadow
      )
      # Draw the type.
      @ppwin.draw_text(
        x: 16,
        y: 58,
        text: "TYPE",
        color: Color.new(72, 72, 72),
        shadow_color: Color::GREYSHADOW,
        small: true
      )
      @ppwin.draw_text(
        x: 52,
        y: 58,
        text: "/" + Type.get(battler.moves[move_index].type).name,
        color: Color.new(72, 72, 72),
        shadow_color: Color::GREYSHADOW
      )
    end

    # Shows a text message.
    # @param text [String] the text to display.
    # @param await_input [Boolean] whether to end the message without needing input.
    # @param ending_arrow [Boolean] whether the message should have a moving down arrow.
    # @param reset [Boolean] whether the message box should clear after the message is done.
    def message(text, await_input = false, ending_arrow = false, reset = true)
      validate \
          text => String,
          await_input => Boolean,
          ending_arrow => Boolean,
          reset => Boolean
      @msgwin.text = text
      @msgwin.ending_arrow = ending_arrow
      @msgwin.letter_by_letter = true
      if await_input
        update while @msgwin.running?
        if reset
          @msgwin.text = ""
          @msgwin.ending_arrow = false
        end
      else
        @msgwin.drawing = true
        update while @msgwin.drawing?
        wait(0.4)
      end
    end

    # Gets the battler to switch out with the current battler.
    # @param battler [Battler] the currently active battler.
    # @return [Integer] the party index of the new battler.
    def switch_battler(battler)
      validate battler => Battler
      ui = PartyUI.start_choose_battler(@battle.sides[0].trainers[0].party.map { |e| e.pokemon }) { update }
      msgwin = MessageWindow.new(
        y: 224,
        z: 3,
        width: 480,
        height: 96,
        windowskin: :choice,
        line_x_start: -16,
        line_y_space: -2,
        line_y_start: -2,
        visible: false,
        viewport: ui.viewport,
        update: proc { ui.update_sprites }
      )
      ret = nil
      loop do
        ret = ui.choose_battler
        if !ret.nil?
          battler = @battle.sides[0].trainers[0].party[ret]
          if @battle.sides[0].battlers.include?(battler)
            # The selected Pokémon is already battling.
            msgwin.ending_arrow = false
            msgwin.visible = true
            msgwin.show("#{battler.name} is already\nin battle!")
            msgwin.visible = false
          else
            ret = battler
            break
          end
        else
          ret = nil
          break
        end
      end
      ui.end_choose_battler
      return ret
    end

    # Shows the animation of recalling the battler back to the party.
    # @apram message [String] the recall message to display.
    # @param battler [Battler] the battler to recall.
    def recall_battler(message, battler)
      validate \
          message => String,
          battler => Battler
      message(message, false)
      # Creates a new flash overlay sprite and bitmap.
      @sprites["white"] = Sprite.new(@viewport)
      @sprites["white"].bitmap = Bitmap.new(System.width, System.height)
      @sprites["white"].bitmap.fill_rect(0, 0, System.width, System.height, Color.new(248, 248, 248))
      @sprites["white"].opacity = 0
      wait(0.1)
      # Creates and runs an animation for the ball opening and closing.
      @ball_animation = BallCloseAnimation.new(@sprites["pokemon1"], @viewport)
      frames = framecount(0.15)
      # Shrinks and shifts the color of the battler to disappear in 0.4 seconds time.
      @sprites["pokemon1"].disappear_into_ball(0.4)
      for i in 1..frames
        update
        @sprites["white"].opacity = 255.0 / framecount(0.25) * i
      end
      frames = framecount(0.1)
      for i in 1..frames
        update
        @sprites["white"].opacity = 255.0 / framecount(0.25) * (framecount(0.15) + i)
        @sprites["pokemon1"].color.alpha += 255.0 / frames
      end
      for i in 1..framecount(0.3)
        update
      end
      @ball_animation = nil
      @sprites["white"].dispose
      @sprites.delete("white")
      @sprites["pokemon1"].dispose
      @sprites.delete("pokemon1")
      @sprites["databox1"].dispose
      @sprites.delete("databox1")
    end

    # Gets the sprite of the given battler.
    # @param battler [Battler] the battler to get the sprite of.
    # @return [BattlerSprite] the sprite of the battler.
    def get_battler_sprite(battler)
      validate battler => Battler
      return battler.side == 0 ? @sprites["pokemon1"] : @sprites["pokemon2"]
    end

    # Gets the databox of the given battler.
    # @param battler [Battler] the battler to get the databox of.
    # @return [BattlerSprite] the databox of the battler.
    def get_battler_databox(battler)
      validate battler => Battler
      return battler.side == 0 ? @sprites["databox1"] : @sprites["databox2"]
    end

    # Shows the faint animation for the given battler.
    # @param battler [Battler] the battler to show fainting.
    def faint(battler)
      validate battler => Battler
      # Get the battler's sprite
      sprite = get_battler_sprite(battler)
      starty = sprite.y
      for i in 1..framecount(0.2)
        update
        # Move the battler down
        sprite.y += 120.0 / framecount(0.4)
      end
      for i in 1..framecount(0.2)
        update
        # Move the battler down and make it invisible
        sprite.y += 120.0 / framecount(0.4)
        sprite.opacity -= 255.0 / framecount(0.2)
      end
      sprite.dispose
      @sprites.delete(@sprites.key(sprite))
      databox = get_battler_databox(battler)
      databox.dispose
      @sprites.delete(@sprites.key(databox))
    end

    # Shows the HP lower animation given a battler and damage.
    # @param battler [Battler] the battler that has its HP lowered.
    # @param damage [Float] the number of HP points to subtract.
    def lower_hp(battler, damage)
      validate \
          battler => Battler,
          damage => Float
      # Get the battler's databox
      databox = get_battler_databox(battler)
      frames = framecount(0.3)
      damage = battler.hp if damage > battler.hp
      diff = damage / frames.to_f
      for i in 1..frames
        update
        # Draw the new HP frame-by-frame
        databox.draw_hp(battler.hp - diff * i)
      end
    end

    # Shows the EXP gain animation given a battler and exp.
    # @param battler [Battler] the battler that is to receive exp.
    # @param exp [Float] the amount of exp to gain.
    def gain_exp(battler, exp)
        validate \
            battler => Battler,
            exp => Float
      # Get the battler's databox
      databox = get_battler_databox(battler)
      frames = framecount(0.7)
      diff = exp / frames.to_f
      for i in 1..frames
        update
        # Draw the new exp frame-by-frame
        databox.draw_exp(battler.exp + diff * i)
      end
    end

    # Shows the level up animation for the given battler
    # @param battler [Battler] the battler that leveled up.
    def level_up(battler)
      validate battler => Battler
      databox = get_battler_databox(battler)
      databox.level_up
      databox.draw_level
      databox.draw_hp
      const_positions = [90, 110, 130, 144, 164, 184, 198]
      positions = const_positions.clone
      particles = []
      2.times do |i|
        until positions.empty?
          p = BasicParticle.new(@viewport)
          x = positions.sample
          positions.delete(x)
          p.load_data({
            bitmap: "gfx/ui/battle/level_up_particle",
            start: {
              x: x,
              y: 224 + rand(96),
              z: 1
            },
            commands: [
              {
                seconds: rand(1..10) / 40.0 + (i == 0 ? 0 : 0.25)
              },
              {
                seconds: 0.25,
                y: 110 + rand(1..35),
                stop: true
              }
            ]
          })
          particles << p
        end
        positions = const_positions if positions.empty?
      end
      until particles.empty?
        update
        particles.each { |p| p.update }
        particles.delete_if { |p| p.disposed? }
      end
    end

    # Shows the levelup stats-up window.
    # @param battler [Battler] the battler that leveled up.
    # @param oldstats [Array<Integer>] the old stats.
    # @param newstats [Array<Integer>] the new stats.
    def stats_up_window(battler, oldstats, newstats)
      validate battler => Battler
      validate_array \
          oldstats => Integer,
          newstats => Integer
      # Find the difference per stat
      diff = newstats.each_with_index.map { |e, i| e - oldstats[i] }
      viewport = Viewport.new(0, 0, System.width, System.height)
      viewport.z = 99999
      # Create a new level up window
      window = LevelUpWindow.new(viewport)
      window.x = 288
      window.y = 112
      # Show the stat increase in the window
      window.show_increase(diff)
      loop do
        update
        window.update
        break if Input.confirm?
      end
      # Show the new stats in the window.
      window.show_stats(newstats)
      loop do
        update
        window.update
        break if Input.confirm?
      end
      window.dispose
    end

    # Shows a stat up or down animation.
    # @param battler [Battler] the battler that has the stat modifier applied.
    # @param stat_type [:up, :down] the type of the animation.
    # @param direction [Symbol] the direction of the animation.
    def stat_anim(battler, stat_type, direction)
      validate \
          battler => Battler,
          stat_type => Symbol,
          direction => Symbol
      # Get the battler's sprite
      sprite = get_battler_sprite(battler)
      # Create a new StatSprite to mask over the battler sprite
      stat = StatSprite.new(@viewport, sprite, stat_type, direction)
      until stat.done?
        System.update
        stat.update
      end
      sprite.visible = true
      stat.dispose
    end
  end
end
