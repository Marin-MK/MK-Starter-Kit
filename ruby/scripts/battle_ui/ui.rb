class Battle
  class UI
    def initialize(battle)
      @battle = battle
      transition = Transition.new
      transition.main
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 9999
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
      @sprites["base1"] = BattleBase.new(@viewport)
      @sprites["base1"].x = Graphics.width + 256
      @sprites["base1"].y = 194
      @sprites["base2"] = BattleBase.new(@viewport, true)
      @sprites["base2"].x = -@sprites["base2"].bitmap.width - 256
      @sprites["base2"].y = 92
      @sprites["trainer1"] = TrainerSprite.new(0, @viewport)
      @sprites["trainer1"].x = Graphics.width + 256
      @sprites["trainer1"].y = 126
      @sprites["trainer1"].z = 1
      if @battle.wild_battle?
        @sprites["pokemon2"] = BattlerSprite.new(@battle.wild_pokemon, true, @viewport)
        @sprites["pokemon2"].color = Color.new(0, 0, 0, 128)
        @sprites["pokemon2"].x = @sprites["base2"].x + 64
        @sprites["pokemon2"].y = 44
        @sprites["pokemon2"].z = 1
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
    end

    def wait(seconds)
      for i in 1..framecount(seconds)
        update
      end
    end

    def update
      Graphics.update
      Input.update
      @sprites["base1"].update
      @sprites["base2"].update
      @sprites["trainer1"].update
      @sprites["pokemon2"].update
      @msgwin.update
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
        @sprites["pokemon2"].x = @sprites["base2"].x + 64
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
        @sprites["pokemon2"].x = @sprites["base2"].x + 64
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
    end
  end
end
