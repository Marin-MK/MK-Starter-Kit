class Trainer
  class Options
    attr_accessor :text_speed
    attr_accessor :battle_scene
    attr_accessor :battle_style
    attr_accessor :sound_mode
    attr_accessor :button_mode
    attr_accessor :frame

    def initialize
      @text_speed = :MID
      @battle_scene = true
      @battle_style = :SHIFT
      @sound_mode = :MONO
      @button_mode = :HELP
      @frame = 1
    end
  end
end
