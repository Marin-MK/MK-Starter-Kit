class BigPanel
  include Disposable

  def initialize(ui, pokemon)
    @ui = ui
    @pokemon = pokemon
    @index = @ui.party.index(@pokemon)
    @viewport = @ui.viewport
    @path = @ui.path
    @sprites = {}
    @sprites["panel"] = SelectableSprite.new(@viewport)
    suffix = ""
    suffix = "_fainted" if @pokemon.fainted?
    @sprites["panel"].bitmap = Bitmap.new(@path + "panel_main" + suffix)
    @sprites["hpbar"] = Sprite.new(@viewport)
    @sprites["hpbar"].bitmap = Bitmap.new("gfx/misc/hpbar")
    @sprites["hp"] = Sprite.new(@viewport)
    @sprites["hp"].bitmap = Bitmap.new("gfx/misc/hp")
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
    @sprites["text"].bitmap = Bitmap.new(@sprites["panel"].src_rect.width, @sprites["panel"].bitmap.height)
    @sprites["text"].bitmap.draw_text(
      {x: 116, y: 90, text: @pokemon.hp.to_s, color: Color.new(248, 248, 248), shadow_color: Color.new(112, 112, 112),
       alignment: :right, small: true},
      {x: 118, y: 90, text: "/", color: Color.new(248, 248, 248), shadow_color: Color.new(112, 112, 112),
       small: true},
      {x: 156, y: 90, text: @pokemon.totalhp.to_s, color: Color.new(248, 248, 248), shadow_color: Color.new(112, 112, 112),
       alignment: :right, small: true},
      {x: 60, y: 40, text: @pokemon.name, color: Color.new(248, 248, 248), shadow_color: Color.new(112, 112, 112),
       small: true}
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
      @sprites["text"].bitmap.draw_text(
        x: 140, y: 58, text: gender_text, color: gender_color, shadow_color: gender_color_shadow,
        small: true
      )
    end
    if !@pokemon.status && !@pokemon.fainted?
      @sprites["text"].bitmap.draw_text(
        x: 76, y: 58, text: symbol(:lv) + @pokemon.level.to_s, color: Color.new(248, 248, 248), shadow_color: Color.new(112, 112, 112),
        small: true
      )
    end
    @sprites["icon"] = PokemonIcon.new(@pokemon, @viewport)
    @sprites["icon"].z = 1
    @sprites["item"] = Sprite.new(@viewport)
    @sprites["item"].bitmap = Bitmap.new(@path + "item") if @pokemon.has_item?
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
    @sprites["hpbar"].x = value + 30
    @sprites["hp"].x = value + 60
    @sprites["icon"].x = value + 28
    @sprites["item"].x = value + 30
    @sprites["status"].x = value + 88
  end

  def y
    return @sprites["panel"].y
  end

  def y=(value)
    @sprites["panel"].y = value
    @sprites["text"].y = value
    @sprites["hpbar"].y = value + 78
    @sprites["hp"].y = value + 82
    @sprites["icon"].y = value + 4
    @sprites["item"].y = value + 58
    @sprites["status"].y = value + 60
  end

  def switching=(value)
    suffix = value ? "_switching" : @pokemon.fainted? ? "_fainted" : ""
    @sprites["panel"].bitmap = Bitmap.new(@path + "panel_main" + suffix)
  end

  def select
    @sprites["panel"].select
    @sprites["icon"].set_frame(1)
    @sprites["icon"].y += 10
    @i = 0
    self.switching = !@ui.switching.nil?
  end

  def deselect
    @sprites["panel"].deselect
    @sprites["icon"].y = self.y + 4
    @i = nil
    self.switching = @ui.switching == @index
  end

  def refresh_item
    if @pokemon.has_item?
      @sprites["item"].bitmap = Bitmap.new(@path + "item")
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
        if @sprites["icon"].y == self.y + 6
          @sprites["icon"].y += 8
        else
          @sprites["icon"].y -= 8
        end
      end
    end
    @sprites["icon"].update unless @pokemon.fainted?
  end
end
