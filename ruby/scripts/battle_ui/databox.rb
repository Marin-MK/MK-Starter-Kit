class Battle
  class Databox
    def initialize(battler, is_opponent)
      @battler = battler
      @is_opponent = is_opponent
      @sprites = {}
      bmp = Bitmap.new(is_opponent ? OPPONENT_BOX_PATH : PLAYER_BOX_PATH)
      @viewport = Viewport.new(0, 0, bmp.width, bmp.height)
      @viewport.z = 100000
      @sprites["box"] = Sprite.new(@viewport)
      @sprites["box"].bitmap = bmp
      @sprites["text"] = Sprite.new(@viewport)
      @sprites["text"].bitmap = Bitmap.new(bmp.width, bmp.height)
      draw_name_and_gender
      draw_level
      draw_owned_ball if $trainer.pokedex.owned?(@battler.pokemon)
      draw_hp_bar
      draw_hp
    end

    def draw_name_and_gender
      @sprites["text"].draw_text(x: NAME_X, y: NAME_Y, text: @battler.name, color: NAME_BASE_COLOR, shadow_color: NAME_SHADOW_COLOR, small: true)
      fontname = @sprites["text"].bitmap.font.name
      @sprites["text"].bitmap.font.name += " Small"
      width = @sprites["text"].bitmap.text_size(@battler.name).width
      @sprites["text"].bitmap.font.name = fontname
      if !@battler.genderless?
        color = @battler.male? ? GENDER_COLOR_MALE : GENDER_COLOR_FEMALE
        @sprites["text"].draw_text(x: NAME_X + width, y: NAME_Y, text: symbol(@battler.male? ? :male : :female), color: color, shadow_color: Color.new(216, 208, 176), small: true)
      end
    end

    def draw_level
      @sprites["text"].draw_text(x: LEVEL_X, y: LEVEL_Y, text: symbol(:lv) + @battler.level.to_s, color: Color.new(64, 64, 64), shadow_color: Color.new(216, 208, 176), small: true, align: :right)
    end

    def draw_owned_ball
      @sprites["owned_ball"] = Sprite.new(@viewport)
      @sprites["owned_ball"].bitmap = Bitmap.new(OWNED_BALL_PATH)
      @sprites["owned_ball"].x = OWNED_BALL_X
      @sprites["owned_ball"].y = OWNED_BALL_Y
    end

    def draw_hp_bar
      @sprites["hp_bar"] = Sprite.new(@viewport)
      @sprites["hp_bar"].bitmap = Bitmap.new(HP_BAR_PATH)
      @sprites["hp_bar"].x = HP_BAR_X
      @sprites["hp_bar"].y = HP_BAR_Y
    end

    def draw_hp(hp = @battler.hp)
      if @sprites["hp"].nil?
        @sprites["hp"] = Sprite.new(@viewport)
        @sprites["hp"].bitmap = Bitmap.new(HP_PATH)
        @sprites["hp"].src_rect.height = @sprites["hp"].bitmap.height / 3
        @sprites["hp"].x = HP_X
        @sprites["hp"].y = HP_Y
      end
      fraction = hp / @battler.totalhp.to_f
      arg = 0
      arg = 1 if fraction < 0.5
      arg = 2 if fraction < 0.25
      @sprites["hp"].src_rect.y = arg * @sprites["hp"].src_rect.height
      @sprites["hp"].src_rect.width = fraction * @sprites["hp"].bitmap.width
    end

    def width
      return @viewport.rect.width
    end

    def height
      return @viewport.rect.height
    end

    def x
      return @viewport.rect.x
    end

    def x=(value)
      @viewport.rect.x = value
    end

    def y
      return @viewport.rect.y
    end

    def y=(value)
      @viewport.rect.y = value
    end

    def z
      return @viewport.z
    end

    def z=(value)
      @viewport.z = value
    end
  end
end
