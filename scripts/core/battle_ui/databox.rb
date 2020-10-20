class Battle
  class Databox
    # Creates a databox for a battler.
    # @param battler [Battler] the battler associated with the databox.
    # @param is_opponent [Boolean] whether this databox belongs to an opponent.
    def initialize(battler, is_opponent)
      validate \
          battler => Battler,
          is_opponent => Boolean
      @battler = battler
      @battle = battler.battle
      @is_opponent = is_opponent
      @sprites = {}
      # Load the databox graphic.
      bmp = Bitmap.new(is_opponent ? OPPONENT_BOX_PATH : PLAYER_BOX_PATH)
      @viewport = Viewport.new(0, 0, bmp.width, bmp.height)
      @viewport.z = 99998
      @sprites["box"] = Sprite.new(@viewport)
      @sprites["box"].bitmap = bmp
      @sprites["text"] = Sprite.new(@viewport)
      @sprites["text"].bitmap = Bitmap.new(bmp.width, bmp.height)
      @sprites["name_gender"] = Sprite.new(@viewport)
      @sprites["name_gender"].bitmap = Bitmap.new(bmp.width, bmp.height)
      @sprites["level"] = Sprite.new(@viewport)
      @sprites["level"].bitmap = Bitmap.new(bmp.width, bmp.height)
      if !opponent?
        @sprites["hp_text"] = Sprite.new(@viewport)
        @sprites["hp_text"].bitmap = Bitmap.new(bmp.width, bmp.height)
      end
      draw_name_and_gender
      draw_level
      draw_owned_ball if $trainer.pokedex.owned?(@battler.pokemon) && is_opponent
      draw_hp_bar
      draw_hp
      draw_exp if !is_opponent
      draw_status_condition
    end

    # @return [Boolean] whether this databox belongs to an opponent.
    def opponent?
      return @is_opponent
    end

    # Draws the battler's name and gender.
    def draw_name_and_gender
      @sprites["name_gender"].bitmap.clear
      name_x = opponent? ? OPPONENT_NAME_X : PLAYER_NAME_X
      name_y = opponent? ? OPPONENT_NAME_Y : PLAYER_NAME_Y
      @sprites["name_gender"].draw_text(x: name_x, y: name_y, text: @battler.pokemon.name, color: BASE_COLOR, shadow_color: SHADOW_COLOR, small: true)
      fontname = @sprites["name_gender"].bitmap.font.name
      @sprites["name_gender"].bitmap.font.name = "fire_red_small"
      width = @sprites["name_gender"].bitmap.text_size(@battler.pokemon.name).width
      @sprites["name_gender"].bitmap.font.name = fontname
      if !@battler.genderless?
        color = @battler.male? ? GENDER_COLOR_MALE : GENDER_COLOR_FEMALE
        @sprites["name_gender"].draw_text(x: name_x + width, y: name_y, text: symbol(@battler.male? ? :male : :female), color: color, shadow_color: SHADOW_COLOR, small: true)
      end
    end

    # Draws the battler's level.
    def draw_level
      @sprites["level"].bitmap.clear
      level_x = opponent? ? OPPONENT_LEVEL_X : PLAYER_LEVEL_X
      level_y = opponent? ? OPPONENT_LEVEL_Y : PLAYER_LEVEL_Y
      @sprites["level"].draw_text(x: level_x, y: level_y, text: symbol(:lv) + @battler.level.to_s, color: BASE_COLOR, shadow_color: SHADOW_COLOR, small: true, align: :right)
    end

    # Draws an "owned" ball in the databox if the battler is already owned by the player.
    def draw_owned_ball
      if @sprites["owned_ball"].nil?
        @sprites["owned_ball"] = Sprite.new(@viewport)
      end
      @sprites["owned_ball"].bitmap = Bitmap.new(OWNED_BALL_PATH)
      @sprites["owned_ball"].x = OWNED_BALL_X
      @sprites["owned_ball"].y = OWNED_BALL_Y
      @sprites["owned_ball"].visible = false if opponent? && !@battler.status.nil?
    end

    # Draws an HP bar.
    def draw_hp_bar
      if @sprites["hp_bar"].nil?
        @sprites["hp_bar"] = Sprite.new(@viewport)
      end
      @sprites["hp_bar"].bitmap.dispose if @sprites["hp_bar"].bitmap
      if opponent?
        if !@battler.status.nil?
          @sprites["hp_bar"].bitmap = Bitmap.new(OPPONENT_HP_BAR_STATUS_PATH)
          @sprites["hp_bar"].x = OPPONENT_HP_BAR_STATUS_X
          @sprites["hp_bar"].y = OPPONENT_HP_BAR_STATUS_Y
        else
          @sprites["hp_bar"].bitmap = Bitmap.new(HP_BAR_PATH)
          @sprites["hp_bar"].x = OPPONENT_HP_BAR_X
          @sprites["hp_bar"].y = OPPONENT_HP_BAR_Y
        end
      else
        @sprites["hp_bar"].bitmap = Bitmap.new(HP_BAR_PATH)
        @sprites["hp_bar"].x = PLAYER_HP_BAR_X
        @sprites["hp_bar"].y = PLAYER_HP_BAR_Y
      end
    end

    # Draws the HP inside the HP bar.
    # @param hp [Float] the amount of HP to draw.
    def draw_hp(hp = @battler.hp)
      validate hp => Float
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

    # Draw the exp inside the exp bar.
    # @param exp [Float] the amount of exp to draw.
    def draw_exp(exp = @battler.exp)
      validte exp => Float
      exp = exp.floor
      if @sprites["exp"].nil?
        @sprites["exp"] = Sprite.new(@viewport)
        @sprites["exp"].bitmap = Bitmap.new(EXP_PATH)
        @sprites["exp"].x = EXP_X
        @sprites["exp"].y = EXP_Y
      end
      rate = @battler.pokemon.species.leveling_rate
      startlevel = EXP.get_exp(rate, EXP.get_level(rate, exp))
      nextlevel = EXP.get_exp(rate, EXP.get_level(rate, exp) + 1)
      fraction = (exp - startlevel) / (nextlevel - startlevel).to_f
      fraction = 0 if fraction < 0 || fraction >= 1
      @sprites["exp"].src_rect.width = fraction * @sprites["exp"].bitmap.width
    end

    # Draw the status conditon.
    def draw_status_condition
      if @sprites["status"].nil?
        @sprites["status"] = StatusConditionIcon.new(@battler, @viewport)
        @sprites["status"].x = opponent? ? OPPONENT_STATUS_X : PLAYER_STATUS_X
        @sprites["status"].y = opponent? ? OPPONENT_STATUS_Y : PLAYER_STATUS_Y
      else
        @sprites["status"].status = @battler.status
      end
    end

    # Show the databox level up animation.
    def level_up
      @sprites["levelup"] = Sprite.new(@viewport)
      @sprites["levelup"].bitmap = Bitmap.new(PLAYER_BOX_LEVEL_UP_PATH)
      @sprites["levelup"].opacity = 0
      frames = framecount(0.15)
      for i in 1..frames
        @battle.ui.update
        @sprites["levelup"].opacity += 200.0 / frames
      end
      for i in 1..frames
        @battle.ui.update
        @sprites["levelup"].opacity -= 200.0 / frames
      end
      @sprites["levelup"].dispose
      @sprites.delete("levelup")
    end

    # Update the databox's displayed status condition.
    def update_status_condition
      draw_status_condition
      draw_hp_bar
      @sprites["owned_ball"].visible = @battler.status.nil? if opponent?
    end

    # @return [Integer] the width of the databox.
    def width
      return @viewport.width
    end

    # @return [Integer] the height of the databox.
    def height
      return @viewport.height
    end

    # @return [Integer] the x position of the databox.
    def x
      return @viewport.x
    end

    # Sets the x position of the databox.
    # @param value [Integer] the new x position of the databox.
    def x=(value)
      validate value => Float
      @viewport.x = value
    end

    # @return [Integer] the y position of the databox.
    def y
      return @viewport.y
    end

    # Sets the y position of the databox.
    # @param value [Integer] the new y position of the databox.
    def y=(value)
      validate value => Float
      @viewport.y = value
    end

    # @return [Integer] the z position of the databox.
    def z
      return @viewport.z
    end

    # Sets the z position of the databox.
    # @param value [Integer] the new z position of the databox.
    def z=(value)
      validate z => Integer
      @viewport.z = value
    end

    # Updates the databox.
    def update
    end

    # Updates the databox and all its sprites.
    def dispose
      @sprites.each_value { |e| e.dispose if !e.disposed? }
      @viewport.dispose
    end

    # @return [Boolean] whether the databox is disposed.
    def disposed?
      return @viewport.disposed?
    end
  end
end
