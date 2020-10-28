class Panel
  include Disposable

  def initialize(ui, pokemon)
    @ui = ui
    @pokemon = pokemon
    @index = @ui.party.index(@pokemon)
    @path = @ui.path
    @viewport = @ui.viewport
    @sprites = {}
    @sprites["panel"] = SelectableSprite.new(@viewport)
    suffix = ""
    suffix = "_fainted" if @pokemon.fainted?
    @sprites["panel"].set_bitmap(@path + "panel" + suffix)
    @sprites["hpbar"] = Sprite.new(@viewport)
    @sprites["hpbar"].set_bitmap("gfx/misc/hpbar")
    @sprites["hp"] = Sprite.new(@viewport)
    @sprites["hp"].set_bitmap("gfx/misc/hp")
    @sprites["hp"].src_rect.height = @sprites["hp"].bitmap.height / 3
    hp_factor = @pokemon.hp / @pokemon.totalhp.to_f
    @sprites["hp"].src_rect.width = @sprites["hp"].bitmap.width * hp_factor
    if @pokemon.hp > 0
      @sprites["hp"].src_rect.width = [@sprites["hp"].src_rect.width, 2].max
    end
    if hp_factor <= 0.25
      @sprites["hp"].src_rect.y = @sprites["hp"].src_rect.height * 2
    elsif hp_factor <= 0.5
      @sprites["hp"].src_rect.y = @sprites["hp"].src_rect.height
    end
    @sprites["text"] = Sprite.new(@viewport)
    @sprites["text"].set_bitmap(@sprites["panel"].src_rect.width, @sprites["panel"].bitmap.height)
    @sprites["text"].draw_text(
      {x: 60, y: 10, text: @pokemon.name, color: Color.new(248, 248, 248), shadow_color: Color.new(112, 112, 112),
       small: true},
      {x: 248, y: 28, text: @pokemon.hp.to_s, color: Color.new(248, 248, 248), shadow_color: Color.new(112, 112, 112),
       small: true, alignment: :right},
      {x: 250, y: 28, text: "/", color: Color.new(248, 248, 248), shadow_color: Color.new(112, 112, 112),
       small: true},
      {x: 288, y: 28, text: @pokemon.totalhp.to_s, color: Color.new(248, 248, 248), shadow_color: Color.new(112, 112, 112),
       small: true, alignment: :right}
    )
    if @pokemon.female?
      gender_text = symbol(:female)
      gender_color = Color.new(248, 152, 144)
      gender_color_shadow = Color.new(152, 64, 56)
    elsif @pokemon.male?
      gender_text = symbol(:male)
      gender_color = Color.new(64, 200, 248)
      gender_color_shadow = Color.new(0, 96, 144)
    end
    if !@pokemon.genderless?
      @sprites["text"].draw_text(
        x: 144, y: 28, text: gender_text, color: gender_color, shadow_color: gender_color_shadow,
        small: true
      )
    end
    if !@pokemon.status && !@pokemon.fainted?
      @sprites["text"].draw_text(
        x: 80, y: 28, text: symbol(:lv) + @pokemon.level.to_s, color: Color.new(248, 248, 248),
        shadow_color: Color.new(112, 112, 112), small: true
      )
    end
    @sprites["icon"] = PokemonIcon.new(@pokemon, @viewport)
    @sprites["icon"].z = 1
    @sprites["item"] = Sprite.new(@viewport)
    @sprites["item"].set_bitmap(@path + "item") if @pokemon.has_item?
    @sprites["item"].z = 2
    @sprites["status"] = StatusConditionIcon.new(@pokemon, @viewport)
    self.x = 0
    self.y = 0
  end

  def x
    return @sprites["panel"].x
  end

  def x=(value)
    @sprites["panel"].x = value
    @sprites["text"].x = value
    @sprites["hpbar"].x = value + 162
    @sprites["hp"].x = value + 192
    @sprites["icon"].x = value + 24
    @sprites["item"].x = value + 34
    @sprites["status"].x = value + 92
  end

  def y
    return @sprites["panel"].y
  end

  def y=(value)
    @sprites["panel"].y = value
    @sprites["text"].y = value
    @sprites["hpbar"].y = value + 14
    @sprites["hp"].y = value + 18
    @sprites["icon"].y = value - 14
    @sprites["item"].y = value + 32
    @sprites["status"].y = value + 28
  end

  def switching=(value)
    suffix = value ? "_switching" : @pokemon.fainted? ? "_fainted" : ""
    @sprites["panel"].set_bitmap(@path + "panel" + suffix)
  end

  def select
    @sprites["panel"].select
    @sprites["icon"].set_frame(1)
    @sprites["icon"].x += 8
    @sprites["icon"].y -= 6
    @i = 0
    self.switching = !@ui.switching.nil?
  end

  def deselect
    @sprites["panel"].deselect
    @sprites["icon"].x -= 8
    @sprites["icon"].y = self.y - 14
    @i = nil
    self.switching = @ui.switching == @index
  end

  def refresh_item
    if @pokemon.has_item?
      @sprites["item"].set_bitmap(@path + "item")
    else
      @sprites["item"].bitmap.clear if @sprites["item"].bitmap
    end
  end

  def update
    if @i
      @i += 1
      time = 0.15
      time = 0.4 if @pokemon.fainted?
      if @i % framecount(time) == 0
        if @sprites["icon"].y == self.y - 20
          @sprites["icon"].y += 8
        else
          @sprites["icon"].y -= 8
        end
      end
    end
    @sprites["icon"].update unless @pokemon.fainted?
  end
end
