class OptionsUI < BaseUI
  def start(pause_ui = nil)
    @pause_ui = pause_ui
    super(path: "options_menu")
    @sprites["header"] = Sprite.new(@viewport)
    @sprites["header"].set_bitmap(@path + "header")
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].set_bitmap(System.width, System.height - 32)
    @sprites["bg"].bitmap.fill_rect(0, 0, System.width, System.height - 32, Color.new(0, 0, 0))
    @sprites["bg"].y = 32
    @sprites["hdrwin"] = SplitSprite.new(@viewport)
    @sprites["hdrwin"].x = 16
    @sprites["hdrwin"].y = 32
    @sprites["hdrwin"].width = 448
    @sprites["hdrwin"].height = 64
    @sprites["hdrwin"].set(Windowskin.get(:helper))
    @sprites["cmdwin"] = SplitSprite.new(@viewport)
    @sprites["cmdwin"].x = 16
    @sprites["cmdwin"].y = 96
    @sprites["cmdwin"].width = 448
    @sprites["cmdwin"].height = 224
    @sprites["cmdwin"].set(Windowskin.get(:choice))
    @sprites["textbg"] = Sprite.new(@viewport)
    @sprites["textbg"].set_bitmap(416, 192)
    @sprites["textbg"].x = 32
    @sprites["textbg"].y = 112
    @sprites["text"] = Sprite.new(@viewport)
    @sprites["text"].z = 1
    @sprites["text"].set_bitmap(System.width, System.height)
    @index = 0
    refresh
  end

  def refresh
    @sprites["textbg"].bitmap.fill_rect(0, 0, 416, 192, Color.new(224, 224, 224))
    @sprites["textbg"].bitmap.fill_rect(0, 4 + 26 * @index, 416, 28, Color.new(248, 248, 248))
    selbasecolor = Color.new(96, 96, 96)
    selshadowcolor = Color.new(208, 208, 200)
    basecolor = Color.new(88, 88, 88)
    shadowcolor = Color.new(184, 184, 176)
    selbasecolorred = Color.new(248, 184, 112)
    selshadowcolorred = Color.new(224, 8, 8)
    basecolorred = Color.new(224, 168, 104)
    shadowcolorred = Color.new(200, 8, 8)
    button_mode = $trainer.options.button_mode == :HELP ? "HELP" : $trainer.options.button_mode == :LR ? "LR" : "L=A"
    @sprites["text"].bitmap.clear
    @sprites["text"].draw_text(
      {x: 48, y: 56, text: "OPTION", color: Color.new(96, 96, 96),
       shadow_color: Color.new(208, 208, 200)},

      {x: 48, y: 122, text: "TEXT SPEED", color: @index == 0 ? selbasecolor : basecolor,
       shadow_color: @index == 0 ? selshadowcolor : shadowcolor},
      {x: 292, y: 122, text: $trainer.options.text_speed.to_s, color: @index == 0 ? selbasecolorred : basecolorred,
       shadow_color: @index == 0 ? selshadowcolorred : shadowcolorred},

      {x: 48, y: 148, text: "BATTLE SCENE", color: @index == 1 ? selbasecolor : basecolor,
       shadow_color: @index == 1 ? selshadowcolor : shadowcolor},
      {x: 292, y: 148, text: $trainer.options.battle_scene ? "ON" : "OFF", color: @index == 1 ? selbasecolorred : basecolorred,
       shadow_color: @index == 1 ? selshadowcolorred : shadowcolorred},

      {x: 48, y: 174, text: "BATTLE STYLE", color: @index == 2 ? selbasecolor : basecolor,
       shadow_color: @index == 2 ? selshadowcolor : shadowcolor},
      {x: 292, y: 174, text: $trainer.options.battle_style.to_s, color: @index == 2 ? selbasecolorred : basecolorred,
       shadow_color: @index == 2 ? selshadowcolorred : shadowcolorred},

      {x: 48, y: 200, text: "SOUND", color: @index == 3 ? selbasecolor : basecolor,
       shadow_color: @index == 3 ? selshadowcolor : shadowcolor},
      {x: 292, y: 200, text: $trainer.options.sound_mode.to_s, color: @index == 3 ? selbasecolorred : basecolorred,
       shadow_color: @index == 3 ? selshadowcolorred : shadowcolorred},

      {x: 48, y: 226, text: "BUTTON MODE", color: @index == 4 ? selbasecolor : basecolor,
       shadow_color: @index == 4 ? selshadowcolor : shadowcolor},
      {x: 292, y: 226, text: button_mode, color: @index == 4 ? selbasecolorred : basecolorred,
       shadow_color: @index == 4 ? selshadowcolorred : shadowcolorred},

      {x: 48, y: 252, text: "FRAME", color: @index == 5 ? selbasecolor : basecolor,
       shadow_color: @index == 5 ? selshadowcolor : shadowcolor},
      {x: 292, y: 252, text: "TYPE " + $trainer.options.frame.to_s, color: @index == 5 ? selbasecolorred : basecolorred,
       shadow_color: @index == 5 ? selshadowcolorred : shadowcolorred},

      {x: 48, y: 278, text: "CANCEL", color: @index == 6 ? selbasecolor : basecolor,
       shadow_color: @index == 6 ? selshadowcolor : shadowcolor}
    )
    if @pause_ui
      @pause_ui.sprites["text"].visible = $trainer.options.button_mode == :HELP
      @pause_ui.sprites["desc"].visible = $trainer.options.button_mode == :HELP
      @pause_ui.cmdwin.windowskin = Windowskin.get(:choice)
    end
  end

  def update
    if Input.cancel? || Input.confirm? && @index == 6
      stop
    end
    if Input.repeat_down?
      Audio.se_play("audio/se/menu_select")
      @index += 1
      @index = 0 if @index > 6
      refresh
    end
    if Input.repeat_up?
      Audio.se_play("audio/se/menu_select")
      @index -= 1
      @index = 6 if @index < 0
      refresh
    end
    if Input.repeat_right?
      Audio.se_play("audio/se/menu_select")
      move_right
      refresh
    end
    if Input.repeat_left?
      Audio.se_play("audio/se/menu_select")
      move_left
      refresh
    end
  end

  def move_right
    case @index
    when 0
      if $trainer.options.text_speed == :FAST
        $trainer.options.text_speed = :SLOW
      elsif $trainer.options.text_speed == :SLOW
        $trainer.options.text_speed = :MID
      else
        $trainer.options.text_speed = :FAST
      end
    when 1
      $trainer.options.battle_scene = !$trainer.options.battle_scene
    when 2
      if $trainer.options.battle_style == :SET
        $trainer.options.battle_style = :SHIFT
      else
        $trainer.options.battle_style = :SET
      end
    when 3
      if $trainer.options.sound_mode == :MONO
        $trainer.options.sound_mode = :STEREO
      else
        $trainer.options.sound_mode = :MONO
      end
    when 4
      if $trainer.options.button_mode == :HELP
        $trainer.options.button_mode = :LR
      elsif $trainer.options.button_mode == :LR
        $trainer.options.button_mode = :LA
      else
        $trainer.options.button_mode = :HELP
      end
    when 5
      $trainer.options.frame += 1
      $trainer.options.frame = 1 if $trainer.options.frame > 10
      @sprites["cmdwin"].set(Windowskin.get(:choice))
    end
  end

  def move_left
    case @index
    when 0
      if $trainer.options.text_speed == :FAST
        $trainer.options.text_speed = :MID
      elsif $trainer.options.text_speed == :MID
        $trainer.options.text_speed = :SLOW
      else
        $trainer.options.text_speed = :FAST
      end
    when 1, 2, 3 # Identical to move_right so call that to avoid duplicate code
      move_right
    when 4
      if $trainer.options.button_mode == :HELP
        $trainer.options.button_mode = :LA
      elsif $trainer.options.button_mode == :LA
        $trainer.options.button_mode = :LR
      else
        $trainer.options.button_mode = :HELP
      end
    when 5
      $trainer.options.frame -= 1
      $trainer.options.frame = 10 if $trainer.options.frame < 1
      @sprites["cmdwin"].set(Windowskin.get(:choice))
    end
  end
end

#s = SplitSprite.new
#s.width = 128
#s.height = 128
#s.set(Windowskin.get(11))

#loop do
#  System.update
#  abort if Input.cancel?
#end
