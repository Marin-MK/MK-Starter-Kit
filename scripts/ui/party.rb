def symbol(n)
  characters = {
    PKMN: "²³",
    Lv: "¤",
    female: "¬",
    male: "£"
  }
  return characters[n] if characters[n]
  raise "Invalid symbol #{n.inspect(32)}"
end

class PartyUI < BaseUI
  class BigPanel
    include Disposable

    def initialize(ui, pokemon)
      super()
      @ui = ui
      @pokemon = pokemon
      @viewport = @ui.viewport
      @path = @ui.path
      @sprites = {}
      @sprites["panel"] = SelectableSprite.new(@viewport)
      suffix = ""
      suffix = "_fainted" if @pokemon.fainted?
      @sprites["panel"].set_bitmap(@path + "panel_main" + suffix)
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
        @sprites["text"].draw_text(
          x: 140, y: 58, text: gender_text, color: gender_color, shadow_color: gender_color_shadow,
          small: true
        )
      end
      if !@pokemon.status && !@pokemon.fainted?
        @sprites["text"].draw_text(
          x: 76, y: 58, text: symbol(:Lv) + @pokemon.level.to_s, color: Color.new(248, 248, 248), shadow_color: Color.new(112, 112, 112),
          small: true
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

    def select
      @sprites["panel"].select
      @sprites["icon"].set_frame(1)
      @sprites["icon"].y += 10
      @i = 0
    end

    def deselect
      @sprites["panel"].deselect
      @sprites["icon"].y = self.y + 4
      @i = nil
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

  class Panel
    include Disposable

    def initialize(ui, pokemon)
      @ui = ui
      @pokemon = pokemon
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
          x: 80, y: 28, text: symbol(:Lv) + @pokemon.level.to_s, color: Color.new(248, 248, 248),
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

    def select
      @sprites["panel"].select
      @sprites["icon"].set_frame(1)
      @sprites["icon"].x += 8
      @sprites["icon"].y -= 6
      @i = 0
    end

    def deselect
      @sprites["panel"].deselect
      @sprites["icon"].x -= 8
      @sprites["icon"].y = self.y - 14
      @i = nil
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

  attr_accessor :party

  def initialize(party = $trainer.party)
    validate_array party => Pokemon
    @party = party.compact
    if !possible?
      raise "Empty party"
    end
    super(path: "party")
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].set_bitmap(@path + "background")
    @sprites["window"] = MessageWindow.new(
      x: 4,
      y: 260,
      viewport: @viewport,
      width: 360,
      height: 56,
      text: "Choose a POKéMON.",
      color: Color.new(96, 96, 96),
      shadow_color: Color.new(208, 208, 200),
      letter_by_letter: false,
      windowskin: 3
    )
    @sprites["cancel"] = SelectableSprite.new(@viewport)
    @sprites["cancel"].set_bitmap(@path + "cancel")
    @sprites["cancel"].x = 368
    @sprites["cancel"].y = 264
    @sprites["panel_0"] = BigPanel.new(self, @party[0])
    @sprites["panel_0"].x = 4
    @sprites["panel_0"].y = 36
    for i in 1...@party.size
      if @party[i]
        @sprites["panel_#{i}"] = Panel.new(self, @party[i])
        @sprites["panel_#{i}"].x = 176
        @sprites["panel_#{i}"].y = 18 + 48 * (i - 1)
      end
    end
    @index = 0
    @sprites["panel_0"].select
  end

  def update
    super
    stop if Input.cancel?
    if Input.repeat_down?
      Audio.se_play("audio/se/menu_select")
      if @index == -1
        @sprites["cancel"].deselect
        @index = 0
        @sprites["panel_0"].select
      elsif @party[@index + 1]
        @sprites["panel_#{@index}"].deselect
        @index += 1
        @sprites["panel_#{@index}"].select
      else
        @sprites["panel_#{@index}"].deselect
        @index = -1
        @sprites["cancel"].select
      end
    end
    if Input.repeat_up?
      Audio.se_play("audio/se/menu_select")
      if @index == -1
        @sprites["cancel"].deselect
        @index = @party.size - 1
        @sprites["panel_#{@index}"].select
      elsif @index > 0
        @sprites["panel_#{@index}"].deselect
        @index -= 1
        @sprites["panel_#{@index}"].select
      else
        @sprites["panel_#{@index}"].deselect
        @index = -1
        @sprites["cancel"].select
      end
    end
    if Input.right? && @party.size > 1 && @index == 0
      Audio.se_play("audio/se/menu_select")
      @sprites["panel_#{@index}"].deselect
      @index = @last_middle_index || 1
      @sprites["panel_#{@index}"].select
    end
    if Input.left? && @index > 0
      Audio.se_play("audio/se/menu_select")
      @sprites["panel_#{@index}"].deselect
      @index = 0
      @sprites["panel_#{@index}"].select
    end
    @last_middle_index = @index if @index > 0
    if Input.confirm?
      if @index == -1 # Cancel
        stop
      else # Pokemon
        # Show list of commands
        $game.start_ui(SummaryUI, @party, @index)
      end
    end
  end

  def stop
    Audio.se_play("audio/se/menu_select") if !stopped?
    super
  end

  def possible?
    return @party.size > 0
  end
end
