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
      if !opponent?
        @sprites["hp_text"] = Sprite.new(@viewport)
        @sprites["hp_text"].bitmap = Bitmap.new(bmp.width, bmp.height)
      end
      draw_name_and_gender
      draw_level
      draw_owned_ball if $trainer.pokedex.owned?(@battler.pokemon) && is_opponent
      draw_hp_bar
      draw_hp
    end

    def opponent?
      return @is_opponent
    end

    def draw_name_and_gender
      name_x = opponent? ? OPPONENT_NAME_X : PLAYER_NAME_X
      name_y = opponent? ? OPPONENT_NAME_Y : PLAYER_NAME_Y
      @sprites["text"].draw_text(x: name_x, y: name_y, text: @battler.pokemon.name, color: BASE_COLOR, shadow_color: SHADOW_COLOR, small: true)
      fontname = @sprites["text"].bitmap.font.name
      @sprites["text"].bitmap.font.name += " Small"
      width = @sprites["text"].bitmap.text_size(@battler.pokemon.name).width
      @sprites["text"].bitmap.font.name = fontname
      if !@battler.genderless?
        color = @battler.male? ? GENDER_COLOR_MALE : GENDER_COLOR_FEMALE
        @sprites["text"].draw_text(x: name_x + width, y: name_y, text: symbol(@battler.male? ? :male : :female), color: color, shadow_color: SHADOW_COLOR, small: true)
      end
    end

    def draw_level
      level_x = opponent? ? OPPONENT_LEVEL_X : PLAYER_LEVEL_X
      level_y = opponent? ? OPPONENT_LEVEL_Y : PLAYER_LEVEL_Y
      @sprites["text"].draw_text(x: level_x, y: level_y, text: symbol(:lv) + @battler.level.to_s, color: BASE_COLOR, shadow_color: SHADOW_COLOR, small: true, align: :right)
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
      @sprites["hp_bar"].x = opponent? ? OPPONENT_HP_BAR_X : PLAYER_HP_BAR_X
      @sprites["hp_bar"].y = opponent? ? OPPONENT_HP_BAR_Y : PLAYER_HP_BAR_Y
    end

    def draw_hp(hp = @battler.hp)
      if @sprites["hp"].nil?
        @sprites["hp"] = Sprite.new(@viewport)
        @sprites["hp"].bitmap = Bitmap.new(HP_PATH)
        @sprites["hp"].src_rect.height = @sprites["hp"].bitmap.height / 3
        @sprites["hp"].x = opponent? ? OPPONENT_HP_X : PLAYER_HP_X
        @sprites["hp"].y = opponent? ? OPPONENT_HP_Y : PLAYER_HP_Y
      end
      fraction = hp / @battler.totalhp.to_f
      arg = 0
      arg = 1 if fraction < 0.5
      arg = 2 if fraction < 0.25
      @sprites["hp"].src_rect.y = arg * @sprites["hp"].src_rect.height
      @sprites["hp"].src_rect.width = fraction * @sprites["hp"].bitmap.width
      if !opponent?
        @sprites["hp_text"].bitmap.clear
        @sprites["hp_text"].draw_text(x: 188, y: 44, text: @battler.totalhp.to_s, color: BASE_COLOR, shadow_color: SHADOW_COLOR, align: :right, small: true)
        @sprites["hp_text"].draw_text(x: 150, y: 44, text: "/", color: BASE_COLOR, shadow_color: SHADOW_COLOR)
        @sprites["hp_text"].draw_text(x: 148, y: 44, text: hp.round.to_s, color: BASE_COLOR, shadow_color: SHADOW_COLOR, align: :right, small: true)
      end
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

    def dispose
      @sprites.each_value { |e| e.dispose if !e.disposed? }
      @viewport.dispose
    end

    def disposed?
      return @viewport.disposed?
    end
  end
end
