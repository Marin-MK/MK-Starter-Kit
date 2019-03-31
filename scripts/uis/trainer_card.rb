class BaseUI; end

class TrainerCardUI < BaseUI
  def initialize
    super(path: "trainer_card")
    suffix = ["_male", "_female"][$trainer.gender]
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].set_bitmap(@path + "background" + suffix)
    @sprites["card"] = Sprite.new(@viewport)
    @sprites["card"].set_bitmap(@path + "card")
    @sprites["trainer"] = Sprite.new(@viewport)
    @sprites["trainer"].set_bitmap(@path + "trainer" + suffix)
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
    @sprites["text"] = Sprite.new(@viewport)
    @sprites["text"].set_bitmap(Graphics.width, Graphics.height)
    @sprites["text"].draw_text(
      {x: 300, y: 42, text: "IDNo." + $trainer.pid.to_s, color: Color.new(96, 96, 96), shadow_color: Color.new(208, 208, 200)},
      {x: 56, y: 80, text: "NAME: " + $trainer.name, color: Color.new(96, 96, 96), shadow_color: Color.new(208, 208, 200)},
      {x: 56, y: 134, text: "MONEY", color: Color.new(96, 96, 96), shadow_color: Color.new(208, 208, 200)},
      {x: 288, y: 134, text: $trainer.get_money_text, color: Color.new(96, 96, 96), shadow_color: Color.new(208, 208, 200),
       alignment: :right},
      {x: 56, y: 198, text: "TIME", color: Color.new(96, 96, 96), shadow_color: Color.new(208, 208, 200)}
    )
    @sprites["time_text"] = Sprite.new(@viewport)
    @sprites["time_text"].set_bitmap(Graphics.width, Graphics.height)
    @sprites["colon"] = Sprite.new(@viewport)
    @sprites["colon"].set_bitmap(10, 20)
    @sprites["colon"].draw_text(text: ":", color: Color.new(96, 96, 96), shadow_color: Color.new(208, 208, 200))
    @sprites["colon"].x = 254
    @sprites["colon"].y = 198
    @sprites["colon"].visible = true
    @page = 0
    @i = (framecount(1.0) / 3.0).ceil # Starts at 1/3rd of the colon flicker animation
    update_sprites
  end

  def update
    super
    if Input.trigger?(Input::B)
      stop
    end
    if Input.trigger?(Input::A)
      if @page == 0 # Flip from Front to Back
        flip_card
      else
        stop
      end
    end
  end

  def flip_card
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
    @sprites["card"].visible = false
    stretched_sprite = Sprite.new(@viewport)
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
    wait(0.4)
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
    wait(0.02)
    @sprites["text"].draw_text(
      x: 292, y: 44, text: $trainer.name, color: Color.new(96, 96, 96), shadow_color: Color.new(208, 208, 200)
    )
  end

  def update_sprites
    super
    if @page == 0 # Front
      hours = (Graphics.frame_count / 60 / 60 / 60 % 60).to_s
      minutes = (Graphics.frame_count / 60 / 60 % 60).to_digits(2)
      if @hours != hours || @minutes != minutes
        @sprites["time_text"].bitmap.clear
        @sprites["time_text"].draw_text(
          {x: 264, y: 198, text: minutes, color: Color.new(96, 96, 96), shadow_color: Color.new(208, 208, 200)},
          {x: 254, y: 198, text: hours, color: Color.new(96, 96, 96), shadow_color: Color.new(208, 208, 200), alignment: :right}
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
