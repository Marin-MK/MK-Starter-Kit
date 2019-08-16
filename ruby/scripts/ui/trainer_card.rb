class TrainerCardUI < BaseUI
  def start
    super(path: "trainer_card")
    @suffix = ["_male", "_female"][$trainer.gender]
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].set_bitmap(@path + "background" + @suffix)
    @sprites["card"] = Sprite.new(@viewport)
    @sprites["card"].set_bitmap(@path + "card")
    @page = 0
    @i = (framecount(1.0) / 3.0).ceil # Starts at 1/3rd of the colon flicker animation
    load_front_page(true)
    update_sprites
    @start = true
  end

  def update
    super
    if @start
      Audio.se_play("audio/se/trainercard")
      @start = false
    end
    if Input.cancel?
      if @page == 1
        load_front_page
      else
        stop
      end
    end
    if Input.confirm?
      if @page == 0 # Flip from Front to Back
        load_back_page
      else
        stop
      end
    end
  end

  def load_front_page(initial = false)
    if !initial
      frames = framecount(0.15)
      increment = 314.0 / frames
      @sprites["text"].visible = false
      @sprites["card"].visible = false
      stretched_sprite = Sprite.new(@viewport)
      Audio.se_play("audio/se/trainercard_flip_start")
      for i in 1..frames
        stretched_sprite.bitmap.dispose if stretched_sprite.bitmap
        stretched_sprite.set_bitmap(Graphics.width, Graphics.height)
        y = (increment * i).round
        stretched_sprite.y = (y / 2.0).round
        stretched_sprite.bitmap.stretch_blt(
          Rect.new(0, 0, @sprites["card"].bitmap.width, @sprites["card"].bitmap.height - y),
          @sprites["card"].bitmap,
          Rect.new(0, 0, @sprites["card"].bitmap.width, @sprites["card"].bitmap.height)
        )
        Graphics.update
        Input.update
      end
      @sprites["card"].set_bitmap(@path + "card")
      wait(0.2)
      Audio.se_play("audio/se/trainercard_flip_end")
      wait(0.2)
      for i in 1..frames
        stretched_sprite.bitmap.dispose if stretched_sprite.bitmap
        stretched_sprite.set_bitmap(Graphics.width, Graphics.height)
        y = [(increment * i).round, 314].min
        stretched_sprite.y = 161 - (y / 2.0).round
        stretched_sprite.bitmap.stretch_blt(
          Rect.new(0, 0, @sprites["card"].bitmap.width, y),
          @sprites["card"].bitmap,
          Rect.new(0, 0, @sprites["card"].bitmap.width, @sprites["card"].bitmap.height)
        )
        Graphics.update
        Input.update
      end
      @sprites["card"].visible = true
      stretched_sprite.dispose
      Audio.se_play("audio/se/trainercard")
      wait(0.02)
    end
    @page = 0
    @sprites["trainer"] = Sprite.new(@viewport)
    @sprites["trainer"].set_bitmap(@path + "trainer" + @suffix)
    @sprites["trainer"].x = 350
    @sprites["trainer"].y = 104
    for i in 1..8
      if $trainer.has_badge?(i)
        @sprites["badge#{i}"] = Sprite.new(@viewport)
        @sprites["badge#{i}"].set_bitmap(@path + "badges")
        @sprites["badge#{i}"].src_rect.width = @sprites["badge#{i}"].bitmap.width / 8
        @sprites["badge#{i}"].src_rect.x = @sprites["badge#{i}"].src_rect.width * (i - 1)
        @sprites["badge#{i}"].x = 64 + 48 * (i - 1)
        @sprites["badge#{i}"].y = 256
      end
    end
    if initial
      @sprites["text"] = Sprite.new(@viewport)
    else
      @sprites["text"].bitmap.clear
      @sprites["text"].visible = true
    end
    @sprites["text"].set_bitmap(Graphics.width, Graphics.height)
    @sprites["text"].draw_text(
      {x: 300, y: 42, text: "IDNo." + $trainer.pid.to_s, color: Color::GREYBASE, shadow_color: Color::GREYSHADOW},
      {x: 56, y: 80, text: "NAME: " + $trainer.name, color: Color::GREYBASE, shadow_color: Color::GREYSHADOW},
      {x: 56, y: 134, text: "MONEY", color: Color::GREYBASE, shadow_color: Color::GREYSHADOW},
      {x: 288, y: 134, text: $trainer.get_money_text, color: Color::GREYBASE, shadow_color: Color::GREYSHADOW,
       alignment: :right},
      {x: 56, y: 198, text: "TIME", color: Color::GREYBASE, shadow_color: Color::GREYSHADOW}
    )
    @sprites["time_text"] = Sprite.new(@viewport)
    @sprites["time_text"].set_bitmap(Graphics.width, Graphics.height)
    @sprites["colon"] = Sprite.new(@viewport)
    @sprites["colon"].set_bitmap(10, 20)
    @sprites["colon"].draw_text(text: ":", color: Color::GREYBASE, shadow_color: Color::GREYSHADOW)
    @sprites["colon"].x = 254
    @sprites["colon"].y = 198
    @sprites["colon"].visible = true
    @sprites["text"].visible = true
    update_sprites(true)
  end

  def load_back_page
    @page = 1
    frames = framecount(0.15)
    increment = 314.0 / frames
    @sprites["text"].visible = false
    @sprites["time_text"].dispose
    @sprites.delete("time_text")
    @sprites["colon"].dispose
    @sprites.delete("colon")
    @sprites["trainer"].dispose
    @sprites.delete("trainer")
    for i in 1..8
      if @sprites["badge#{i}"]
        @sprites["badge#{i}"].dispose
        @sprites.delete("badge#{i}")
      end
    end
    @sprites["card"].visible = false
    stretched_sprite = Sprite.new(@viewport)
    Audio.se_play("audio/se/trainercard_flip_start")
    for i in 1..frames
      stretched_sprite.bitmap.dispose if stretched_sprite.bitmap
      stretched_sprite.set_bitmap(Graphics.width, Graphics.height)
      y = (increment * i).round
      stretched_sprite.y = (y / 2.0).round
      stretched_sprite.bitmap.stretch_blt(
        Rect.new(0, 0, @sprites["card"].bitmap.width, @sprites["card"].bitmap.height - y),
        @sprites["card"].bitmap,
        Rect.new(0, 0, @sprites["card"].bitmap.width, @sprites["card"].bitmap.height)
      )
      Graphics.update
      Input.update
    end
    @sprites["card"].set_bitmap(@path + "card_back")
    wait(0.2)
    Audio.se_play("audio/se/trainercard_flip_end")
    wait(0.2)
    for i in 1..frames
      stretched_sprite.bitmap.dispose if stretched_sprite.bitmap
      stretched_sprite.set_bitmap(Graphics.width, Graphics.height)
      y = [(increment * i).round, 314].min
      stretched_sprite.y = 161 - (y / 2.0).round
      stretched_sprite.bitmap.stretch_blt(
        Rect.new(0, 0, @sprites["card"].bitmap.width, y),
        @sprites["card"].bitmap,
        Rect.new(0, 0, @sprites["card"].bitmap.width, @sprites["card"].bitmap.height)
      )
      Graphics.update
      Input.update
    end
    @sprites["card"].visible = true
    stretched_sprite.dispose
    @sprites["text"].bitmap.clear
    @sprites["text"].visible = true
    Audio.se_play("audio/se/trainercard")
    wait(0.02)
    @sprites["text"].draw_text(
      x: 292, y: 44, text: $trainer.name, color: Color::GREYBASE, shadow_color: Color::GREYSHADOW
    )
  end

  def update_sprites(force_update_time = false)
    super()
    if @page == 0 # Front
      hours = (Graphics.frame_count / 60 / 60 / 60 % 60).to_s
      minutes = (Graphics.frame_count / 60 / 60 % 60).to_digits(2)
      if @hours != hours || @minutes != minutes || force_update_time
        @sprites["time_text"].bitmap.clear
        @sprites["time_text"].draw_text(
          {x: 264, y: 198, text: minutes, color: Color::GREYBASE, shadow_color: Color::GREYSHADOW},
          {x: 254, y: 198, text: hours, color: Color::GREYBASE, shadow_color: Color::GREYSHADOW, alignment: :right}
        )
      end
      @hours = hours
      @minutes = minutes
      @i += 1
      if @i % framecount(1.0) == 0
        @i = 0
        @sprites["colon"].visible = !@sprites["colon"].visible
      end
    else # Back

    end
  end
end
