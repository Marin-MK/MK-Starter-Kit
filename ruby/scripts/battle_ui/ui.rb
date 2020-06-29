class Battle
  class UI
    attr_accessor :viewport
    attr_accessor :sprites

    def initialize(battle)
      @battle = battle
      transition = Transition.new
      transition.main
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99997
      @sprites = {}
      @sprites["blackbg1"] = Sprite.new(@viewport)
      @sprites["blackbg1"].bitmap = Bitmap.new(Graphics.width, Graphics.height / 2)
      @sprites["blackbg1"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height / 2, Color.new(0, 0, 0))
      @sprites["blackbg1"].z = 999999
      @sprites["blackbg2"] = Sprite.new(@viewport)
      @sprites["blackbg2"].bitmap = Bitmap.new(Graphics.width, Graphics.height / 2)
      @sprites["blackbg2"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height / 2, Color.new(0, 0, 0))
      @sprites["blackbg2"].y = @sprites["blackbg1"].bitmap.height
      @sprites["blackbg2"].z = 999999
      @sprites["bg"] = Sprite.new(@viewport)
      @sprites["bg"].bitmap = Bitmap.new("gfx/ui/battle/backdrops/standard")
      @sprites["bg"].z = -2
      @sprites["base1"] = BattleBase.new(@viewport)
      @sprites["base1"].x = Graphics.width + 256
      @sprites["base1"].y = 194
      @sprites["base1"].z = -1
      @sprites["base2"] = BattleBase.new(@viewport, true)
      @sprites["base2"].x = -@sprites["base2"].bitmap.width - 256
      @sprites["base2"].y = 92
      @sprites["base2"].z = -1
      @sprites["trainer1"] = TrainerSprite.new(0, @viewport)
      @sprites["trainer1"].x = Graphics.width + 256
      @sprites["trainer1"].y = 126
      if @battle.wild_battle?
        @sprites["pokemon2"] = BattlerSprite.new(@battle.wild_pokemon, true, @viewport)
        @sprites["pokemon2"].color = Color.new(0, 0, 0, 128)
        @sprites["pokemon2"].x = @sprites["base2"].x + 64 + @battle.wild_pokemon.pokemon.species.battler_front_x
        @sprites["pokemon2"].y = 44 + @battle.wild_pokemon.pokemon.species.battler_front_y
      end
      @sprites["grass"] = Sprite.new(@viewport)
      @sprites["grass"].bitmap = Bitmap.new("gfx/ui/battle/backdrops/standard_grass")
      @sprites["grass"].y = 130
      @sprites["grass"].z = 2
      @msgwin = MessageWindow.new(
        y: 224,
        z: 3,
        viewport: @viewport,
        width: Graphics.width,
        height: 96,
        text: "",
        letter_by_letter: false,
        color: Color::LIGHTBASE,
        shadow_color: Color.new(104, 88, 112),
        windowskin: :battle
      )
      @last_move_index = 0
    end

    def dispose
      @sprites.each_value { |e| e.dispose if !e.disposed? }
      @msgwin.dispose
      @viewport.dispose
    end

    def wait(seconds)
      for i in 1..framecount(seconds)
        update
      end
    end

    def update(update_main = true)
      if update_main
        Graphics.update
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

    def begin_start
      wait(0.2)
      frames = framecount(0.8)
      startbase1 = @sprites["base1"].x
      startbase2 = @sprites["base2"].x
      diffblack = @sprites["blackbg2"].y / frames.to_f
      diffbase1 = (startbase1 - 8) / frames.to_f / 2.0
      diffbase2 = (-startbase2 + 224) / frames.to_f / 2.0
      for i in 1..frames
        update
        @sprites["blackbg1"].y = -diffblack * i
        @sprites["blackbg2"].y = Graphics.height / 2 + diffblack * i
        @sprites["grass"].x -= 10
        @sprites["base1"].x = startbase1 - diffbase1 * i
        @sprites["base2"].x = startbase2 + diffbase2 * i
        @sprites["trainer1"].x = @sprites["base1"].x + 100
        @sprites["pokemon2"].x = @sprites["base2"].x + 64 + @sprites["pokemon2"].pokemon.species.battler_front_x
      end
      @sprites["blackbg1"].dispose
      @sprites["blackbg2"].dispose
      frames = framecount(0.8)
      startbase1 = @sprites["base1"].x
      startbase2 = @sprites["base2"].x
      for i in 1..frames
        update
        @sprites["grass"].x -= 10
        @sprites["grass"].y += 3
        @sprites["base1"].x = startbase1 - diffbase1 * i
        @sprites["base2"].x = startbase2 + diffbase2 * i
        @sprites["trainer1"].x = @sprites["base1"].x + 100
        @sprites["pokemon2"].x = @sprites["base2"].x + 64 + @sprites["pokemon2"].pokemon.species.battler_front_x
      end
      @sprites["grass"].dispose
    end

    def finish_start(intro_message)
      @msgwin.letter_by_letter = true
      @msgwin.ending_arrow = true
      @msgwin.text = intro_message
      @sprites["databox2"] = Databox.new(@battle.wild_pokemon, true)
      @sprites["databox2"].x = -@sprites["databox2"].width
      @sprites["databox2"].y = 32
      frames = framecount(0.4)
      diffx = (-@sprites["databox2"].x + 26) / frames.to_f
      for i in 1..frames
        update
        @sprites["databox2"].x = -@sprites["databox2"].width + diffx * i
        @sprites["pokemon2"].color.alpha = 128.0 / frames * (frames - i) if @sprites["pokemon2"].color.alpha > 0
      end
      @sprites["pokemon2"].color.alpha = 0
      update while @msgwin.running?
      @msgwin.text = ""
      @msgwin.ending_arrow = false
    end

    def send_out_initial_pokemon(message, battler)
      message(message, false)
      frames = framecount(0.5)
      diffx = (@sprites["trainer1"].src_rect.width + 108) / frames.to_f
      @sprites["trainer1"].frame = 1
      for i in 1..frames
        update
        @sprites["trainer1"].x = 108 - diffx * i
        if i >= framecount(0.1) && @sprites["trainer1"].frame == 1 ||
           i >= framecount(0.2) && @sprites["trainer1"].frame == 2 ||
           i >= framecount(0.3) && @sprites["trainer1"].frame == 3
          @sprites["trainer1"].frame += 1
          if @sprites["trainer1"].frame == 4
            throw_ball(battler)
          end
        end
      end
      update until @sprites["ball"].almost_done?
      send_out_pokemon(nil, battler, false)
    end

    def throw_ball(battler)
      @sprites["ball"] = BallSprite.new(battler.ball_used, @viewport)
      @sprites["ball"].update
    end

    def send_out_pokemon(msg, battler, throw = true)
      if msg
        message(msg, false)
      end
      if throw
        throw_ball(battler)
        update until @sprites["ball"].almost_done?
      end
      @sprites["pokemon1"] = BattlerSprite.new(battler, false, @viewport)
      @sprites["pokemon1"].x = 80 + battler.pokemon.species.battler_back_x
      @sprites["pokemon1"].y = 226 - @sprites["pokemon1"].src_rect.height + battler.pokemon.species.battler_back_y
      @sprites["pokemon1"].color = Color.new(248, 176, 240)
      @sprites["pokemon1"].appear_from_ball(0.4)
      @sprites["white"] = Sprite.new(@viewport)
      @sprites["white"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
      @sprites["white"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(248, 248, 248))
      @sprites["white"].opacity = 0
      wait(0.1)
      frames = framecount(0.15)
      for i in 1..frames
        update
        @sprites["white"].opacity = 255.0 / framecount(0.25) * i
      end
      @ball_animation = BallOpenAnimation.new(@sprites["pokemon1"], @viewport)
      frames = framecount(0.1)
      for i in 1..frames
        update
        @sprites["white"].opacity = 255.0 / framecount(0.25) * (framecount(0.15) + i)
      end
      @sprites["databox1"] = Databox.new(battler, false)
      @sprites["databox1"].x = Graphics.width
      @sprites["databox1"].y = 148
      frames = framecount(0.2)
      diffx = (Graphics.width - 252) / frames.to_f
      for i in 1..frames
        update
        @sprites["pokemon1"].color.alpha = 255.0 - 255.0 / frames * i
        @sprites["white"].opacity = 255.0 - 255.0 / frames * i
        @sprites["databox1"].x = Graphics.width - diffx * i
      end
      @sprites["white"].dispose
      @sprites.delete("white")
    end

    def fade_out
      vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
      vp.z = 999999
      blackbg = Sprite.new(vp)
      blackbg.bitmap = Bitmap.new(Graphics.width, Graphics.height)
      blackbg.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
      blackbg.opacity = 0
      blackbg.z = 999999
      frames = framecount(0.6)
      for i in 1..frames
        update
        blackbg.opacity = 255.0 / frames * i
      end
      dispose
      for i in 1..framecount(0.2)
        Graphics.update
      end
      for i in 1..frames
        Graphics.update
        blackbg.opacity = 255.0 / frames * (frames - i)
      end
      blackbg.dispose
      vp.dispose
    end

    def choose_command(battler)
      @msgwin.text = "What will\n#{battler.name} do?"
      @msgwin.letter_by_letter = false
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

    def choose_move(battler, initial_index = @last_move_index)
      choices = [["-", "-"], ["-", "-"]]
      for i in 0...battler.moves.size
        choices[i / 2][i % 2] = battler.moves[i].name
      end
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
      @ppwin = BaseWindow.new(160, 96, :battle_choice, @viewport)
      @ppwin.x = 320
      @ppwin.y = 224
      @ppwin.z = 4
      draw_move_info(battler, initial_index)
      cmd = nil
      loop do
        update
        oldidx = @cmdwin.index
        cmd = @cmdwin.update(false)
        if choices[@cmdwin.index / 2][@cmdwin.index % 2] == "-"
          @cmdwin.set_index(oldidx, false)
        end
        if oldidx != @cmdwin.index
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

    def draw_move_info(battler, move_index)
      pp_base = Color.new(32, 32, 32)
      pp_shadow = Color.new(208, 208, 200)
      fraction = battler.moves[move_index].pp / battler.moves[move_index].totalpp.to_f
      if fraction == 0
        pp_base = Color.new(232, 0, 0)
        pp_shadow = Color.new(240, 216, 152)
      elsif fraction < 0.25
        pp_base = Color.new(248, 144, 0)
        pp_shadow = Color.new(248, 232, 112)
      elsif fraction < 0.5
        pp_base = Color.new(232, 216, 0)
        pp_shadow = Color.new(248, 240, 136)
      end
      @ppwin.clear
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

    def message(text, await_input = false, ending_arrow = false, reset = true)
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

    def switch_battler(battler)
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

    def recall_battler(message, battler)
      message(message, false)
      @sprites["white"] = Sprite.new(@viewport)
      @sprites["white"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
      @sprites["white"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(248, 248, 248))
      @sprites["white"].opacity = 0
      wait(0.1)
      @ball_animation = BallCloseAnimation.new(@sprites["pokemon1"], @viewport)
      frames = framecount(0.15)
      @sprites["pokemon1"].disappear_into_ball(0.4)
      for i in 1..frames
        update
        @sprites["white"].opacity = 255.0 / framecount(0.25) * i
      end
      frames = framecount(0.1)
      for i in 1..frames
        update
        @sprites["white"].opacity = 255.0 / framecount(0.25) * (framecount(0.15) + i)
        @sprites["pokemon1"].color.alpha = 255.0 / frames * i
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

    def get_battler_sprite(battler)
      return battler.side == 0 ? @sprites["pokemon1"] : @sprites["pokemon2"]
    end

    def get_battler_databox(battler)
      return battler.side == 0 ? @sprites["databox1"] : @sprites["databox2"]
    end

    def faint(battler)
      sprite = get_battler_sprite(battler)
      starty = sprite.y
      for i in 1..framecount(0.2)
        update
        sprite.y = starty + 120.0 / framecount(0.4) * i
      end
      for i in 1..framecount(0.2)
        update
        sprite.y = starty + 120.0 / framecount(0.2) * (framecount(0.2) + i)
        sprite.opacity = 255.0 * (framecount(0.2) - i)
      end
      sprite.dispose
      @sprites.delete(@sprites.key(sprite))
      databox = get_battler_databox(battler)
      databox.dispose
      @sprites.delete(@sprites.key(databox))
    end

    def lower_hp(battler, damage)
      databox = get_battler_databox(battler)
      frames = framecount(0.3)
      damage = battler.hp if damage > battler.hp
      diff = damage / frames.to_f
      for i in 1..frames
        update
        databox.draw_hp(battler.hp - diff * i)
      end
    end

    def gain_exp(battler, exp)
      databox = get_battler_databox(battler)
      frames = framecount(0.7)
      diff = exp / frames.to_f
      for i in 1..frames
        update
        databox.draw_exp(battler.exp + diff * i)
      end
    end

    def level_up(battler)
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

    def stats_up_window(battler, oldstats, newstats)
      diff = newstats.each_with_index.map { |e, i| e - oldstats[i] }
      viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      viewport.z = 99999
      window = LevelUpWindow.new(viewport)
      window.x = 288
      window.y = 112
      window.show_increase(diff)
      loop do
        update
        window.update
        break if Input.confirm?
      end
      window.show_stats(newstats)
      loop do
        update
        window.update
        break if Input.confirm?
      end
      window.dispose
    end

    def stat_anim(battler, stat_type, direction)
      return
      sprite = get_battler_sprite(battler)
      stat = StatSprite.new(@viewport, sprite, stat_type, direction)
      frames = framecount(2.0)
      Graphics.update
      for i in 1..frames
        Graphics.update
        stat.update
      end
      sprite.visible = true
      stat.dispose
    end
  end
end
