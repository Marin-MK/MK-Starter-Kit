class SummaryUI < BaseUI
  def start(party, party_index = nil)
    super(path: "summary")
    if party.is_a?(PartyUI)
      @party_ui = party
      @party = @party_ui.party
      @party_index = @party_ui.index
    else
      @party = party
      @party_index = party_index
    end
    @pokemon = @party[@party_index]
    @sprites["header"] = Sprite.new(@viewport)
    suffix = @pokemon.shiny? ? "_shiny" : ""
    @sprites["bg_1"] = Sprite.new(@viewport)
    @sprites["bg_1"].set_bitmap(@path + "background_panel_1" + suffix)
    @sprites["bg_1"].y = 32
    @sprites["bg_1"].z = -1
    @sprites["bg_2"] = Sprite.new(@viewport)
    @sprites["bg_2"].set_bitmap(@path + "background_panel_2" + suffix)
    @sprites["bg_2"].y = 64
    @sprites["bg_2"].z = -3
    if @pokemon.shiny?
      @sprites["shiny"] = Sprite.new(@viewport)
      @sprites["shiny"].set_bitmap(@path + "shiny")
      @sprites["shiny"].x = 204
      @sprites["shiny"].y = 72
    end
    @sprites["panel"] = Sprite.new(@viewport)
    @sprites["panel"].y = 32
    @sprites["text"] = Sprite.new(@viewport)
    @sprites["text"].set_bitmap(Graphics.width, Graphics.height)
    @sprites["text"].z = 1
    @sprites["vartext"] = Sprite.new(@viewport)
    @sprites["vartext"].set_bitmap(Graphics.width, Graphics.height)
    @sprites["vartext"].z = 1
    @page = 1
    change_pokemon(@party_index)
    @i = -framecount(0.25) if !@pokemon.fainted?
    @amplitude = 3
    if @pokemon.hp / @pokemon.totalhp.to_f <= 0.25
      @amplitude = 1
    elsif @pokemon.hp / @pokemon.totalhp.to_f <= 0.5
      @amplitude = 2
    end
    load_page_1
  end

  def change_pokemon(new_index)
    @party_index = new_index
    @pokemon = @party[@party_index]
    @sprites["vartext"].bitmap.clear if @sprites["vartext"]
    @sprites["text"].bitmap.clear if @sprites["text"]
    @sprites["shiny"].dispose if @sprites["shiny"]
    if @pokemon.shiny?
      @sprites["shiny"] = Sprite.new(@viewport)
      @sprites["shiny"].set_bitmap(@path + "shiny")
      @sprites["shiny"].x = 204
      @sprites["shiny"].y = 72
      @sprites["bg_1"].set_bitmap(@path + "background_panel_1_shiny")
      @sprites["bg_2"].set_bitmap(@path + "background_panel_2_shiny")
    else
      @sprites["shiny"].dispose if @sprites["shiny"]
      @sprites["bg_1"].set_bitmap(@path + "background_panel_1")
      @sprites["bg_2"].set_bitmap(@path + "background_panel_2")
    end
    indexes = {
      :POKEBALL => 0,
      :GREATBALL => 1,
      :ULTRABALL => 2,
      :MASTERBALL => 3,
      :SAFARIBALL => 4,
      :PREMIUMBALL => 5,
      :REPEATBALL => 6,
      :TIMERBALL => 7,
      :NESTBALL => 8,
      :NETBALL => 9,
      :DIVEBALL => 10,
      :LUXURYBALL => 11
    }
    @sprites["ball"].dispose if @sprites["ball"]
    @sprites["ball"] = Sprite.new(@viewport)
    @sprites["ball"].set_bitmap(@path + "balls")
    @sprites["ball"].src_rect.height = @sprites["ball"].bitmap.height / indexes.size
    @sprites["ball"].src_rect.y = indexes[@pokemon.ball_used] * @sprites["ball"].src_rect.height
    @sprites["ball"].x = 200
    @sprites["ball"].y = 164
    @sprites["status"].dispose if @sprites["status"]
    @sprites["status"] = StatusConditionIcon.new(@pokemon, @viewport)
    @sprites["status"].x = 12
    @sprites["status"].y = 68
    @sprites["pokemon"].dispose if @sprites["pokemon"]
    @sprites["pokemon"] = PokemonBattlerSprite.new(@pokemon, @viewport)
    @sprites["pokemon"].mirror = true
    @sprites["pokemon"].x = 56
    @sprites["pokemon"].y = 66
    @sprites["pokemon"].z = -2
    @i = 0 if !@pokemon.fainted?
    @amplitude = 3
    if @pokemon.hp / @pokemon.totalhp.to_f <= 0.25
      @amplitude = 1
    elsif @pokemon.hp / @pokemon.totalhp.to_f <= 0.5
      @amplitude = 2
    end
    case @page
    when 1; load_page_1(true)
    when 2; load_page_2(true)
    when 3; load_page_3(true)
    end
  end

  def preload_page_1
    sprites = {}
    sprites["panel"] = Sprite.new(@viewport)
    sprites["panel"].set_bitmap(@path + "page_1")
    sprites["panel"].y = 32
    return sprites
  end

  def load_page_1(ignore_wait = false)
    @sprites["header"].set_bitmap(@path + "page_1_header")
    sprites = preload_page_1
    @sprites["text"].bitmap.clear
    @sprites["text"].draw_text(
      {x: 8, y: 8, text: "POKéMON INFO", color: Color.new(248, 248, 248),
       shadow_color: Color.new(96, 96, 96)},
      {x: 8, y: 42, text: symbol(:Lv) + @pokemon.level.to_s, color: Color.new(248, 248, 248),
       shadow_color: Color.new(96, 96, 96)},
      {x: 80, y: 42, text: @pokemon.name, color: Color.new(248, 248, 248),
       shadow_color: Color.new(96, 96, 96)}
    )
    if @pokemon.female?
      gender_text = symbol(:female)
      gender_color = Color.new(248, 184, 112)
      gender_color_shadow = Color.new(224, 8, 8)
    elsif @pokemon.male?
      gender_text = symbol(:male)
      gender_color = Color.new(64, 200, 248)
      gender_color_shadow = Color.new(0, 96, 144)
    end
    if !@pokemon.genderless?
      @sprites["text"].draw_text(
        x: 210, y: 42, text: gender_text, color: gender_color, shadow_color: gender_color_shadow
      )
    end
    @sprites["type1"].dispose if @sprites["type1"]
    @sprites["type2"].dispose if @sprites["type2"]
    if @page == 2
      @sprites["vartext"].visible = false
      @sprites["hpbar"].dispose
      @sprites["hp"].dispose
      @sprites["expbar"].dispose
      @sprites["exp"].dispose
      sprites["panel"].z = 1
      frames = framecount(0.08)
      increment = Graphics.width / frames.to_f
      sprites["panel"].x += Graphics.width
      for i in 1..frames
        Graphics.update
        Input.update
        update_sprites
        sprites["panel"].x = Graphics.width - increment * i
      end
      @sprites["panel"].dispose
      @sprites["vartext"].bitmap.clear
      @sprites["vartext"].visible = true
      sprites["panel"].z = 0
    end
    @sprites["panel"] = sprites["panel"]
    wait(0.1) unless ignore_wait
    @sprites["vartext"].draw_text(
      {x: 334, y: 48, text: @pokemon.species.id.to_digits(3), color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192)},
      {x: 334, y: 76, text: @pokemon.species.name, color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192)},
      {x: 334, y: 136, text: @pokemon.ot_name, color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192)},
      {x: 334, y: 166, text: (@pokemon.ot_pid || 0).to_s, color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192)},
      {x: 16, y: 236, text: @pokemon.nature.name + " nature.", color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192)}
    )
    itemtext = @pokemon.has_item? ? @pokemon.item.name : "NONE"
    @sprites["vartext"].draw_text(
      x: 334, y: 196, text: itemtext, color: Color.new(64, 64, 64),
      shadow_color: Color.new(216, 216, 192)
    )
    obtaintext = nil
    if @pokemon.obtain_type == :MET
      obtaintext = "Met in " + MKD::Map.fetch(@pokemon.obtain_map).name + " at " + symbol(:Lv) + " " + @pokemon.obtain_level.to_s + "."
    end
    if obtaintext
      @sprites["vartext"].draw_text(
        x: 16, y: 264, text: obtaintext, color: Color.new(64, 64, 64),
        shadow_color: Color.new(216, 216, 192)
      )
    end
    @sprites["type1"] = TypeIcon.new(@pokemon.type1, @viewport)
    @sprites["type1"].x = 334
    @sprites["type1"].y = 102
    if @pokemon.type2
      @sprites["type2"] = TypeIcon.new(@pokemon.type2, @viewport)
      @sprites["type2"].x = 406
      @sprites["type2"].y = 102
    end
    @page = 1
  end

  def preload_page_2
    sprites = {}
    sprites["panel"] = Sprite.new(@viewport)
    sprites["panel"].set_bitmap(@path + "page_2")
    sprites["panel"].y = 32
    sprites["hpbar"] = Sprite.new(@viewport)
    sprites["hpbar"].set_bitmap("gfx/misc/hpbar")
    sprites["hpbar"].x = 338
    sprites["hpbar"].y = 64
    sprites["hp"] = Sprite.new(@viewport)
    sprites["hp"].set_bitmap("gfx/misc/hp")
    sprites["hp"].src_rect.height = sprites["hp"].bitmap.height / 3
    factor = @pokemon.hp / @pokemon.totalhp.to_f
    sprites["hp"].src_rect.width = factor * sprites["hp"].bitmap.width
    sprites["hp"].src_rect.width = 1 if sprites["hp"].src_rect.width < 1 && @pokemon.hp > 0
    sprites["hp"].src_rect.y = 1 * sprites["hp"].src_rect.height if factor <= 0.5
    sprites["hp"].src_rect.y = 2 * sprites["hp"].src_rect.height if factor <= 0.25
    sprites["hp"].x = 368
    sprites["hp"].y = 68
    sprites["expbar"] = Sprite.new(@viewport)
    sprites["expbar"].set_bitmap(@path + "expbar")
    sprites["expbar"].x = 304
    sprites["expbar"].y = 256
    sprites["exp"] = Sprite.new(@viewport)
    sprites["exp"].set_bitmap(@path + "exp")
    endexp = @pokemon.exp
    if @pokemon.level < 100
      beginexp = EXP.get_exp(@pokemon.species.leveling_rate(@pokemon.form), @pokemon.level)
      endexp = EXP.get_exp(@pokemon.species.leveling_rate(@pokemon.form), @pokemon.level + 1)
      total = endexp - beginexp
      sprites["exp"].src_rect.width = (@pokemon.exp - beginexp) / total.to_f * sprites["exp"].bitmap.width
    else
      sprites["exp"].src_rect.width = 0
    end
    sprites["exp"].x = 336
    sprites["exp"].y = 260
    return sprites
  end

  def load_page_2(ignore_wait = false)
    @sprites["text"].bitmap.clear
    @sprites["text"].draw_text(
      {x: 8, y: 8, text: "POKéMON SKILLS", color: Color.new(248, 248, 248),
       shadow_color: Color.new(96, 96, 96)},
      {x: 8, y: 42, text: symbol(:Lv) + @pokemon.level.to_s, color: Color.new(248, 248, 248),
       shadow_color: Color.new(96, 96, 96)},
      {x: 80, y: 42, text: @pokemon.name, color: Color.new(248, 248, 248),
       shadow_color: Color.new(96, 96, 96)}
    )
    if @pokemon.female?
      gender_text = symbol(:female)
      gender_color = Color.new(248, 184, 112)
      gender_color_shadow = Color.new(224, 8, 8)
    elsif @pokemon.male?
      gender_text = symbol(:male)
      gender_color = Color.new(64, 200, 248)
      gender_color_shadow = Color.new(0, 96, 144)
    end
    if !@pokemon.genderless?
      @sprites["text"].draw_text(
        x: 210, y: 42, text: gender_text, color: gender_color, shadow_color: gender_color_shadow
      )
    end
    @sprites["header"].set_bitmap(@path + "page_2_header")
    sprites = preload_page_2
    @sprites["hpbar"].dispose if @sprites["hpbar"]
    @sprites["hp"].dispose if @sprites["hp"]
    @sprites["expbar"].dispose if @sprites["expbar"]
    @sprites["exp"].dispose if @sprites["exp"]
    if @page == 1
      @sprites["vartext"].visible = false
      @sprites["type1"].dispose
      @sprites["type2"].dispose if @sprites["type2"]
      @sprites["panel"].z = 1
      frames = framecount(0.08)
      increment = Graphics.width / frames.to_f
      for i in 1..frames
        Graphics.update
        Input.update
        update_sprites
        @sprites["panel"].x = increment * i
      end
      @sprites["panel"].dispose
      @sprites["vartext"].bitmap.clear
      @sprites["vartext"].visible = true
    elsif @page == 3
      @sprites["vartext"].visible = false
      for i in 0...4
        @sprites["type_#{i}"].dispose if @sprites["type_#{i}"]
      end
      sprites["panel"].z = 1
      frames = framecount(0.08)
      increment = Graphics.width / frames.to_f
      positions = {}
      sprites.keys.each do |key|
        positions[key] = sprites[key].x
        sprites[key].x += Graphics.width
      end
      for i in 1..frames
        Graphics.update
        Input.update
        update_sprites
        sprites.keys.each do |key|
          sprites[key].x = positions[key] + Graphics.width - increment * i
        end
      end
      @sprites["panel"].dispose
      @sprites["vartext"].bitmap.clear
      @sprites["vartext"].visible = true
      sprites["panel"].z = 0
    end
    @sprites["panel"] = sprites["panel"]
    @sprites["hpbar"] = sprites["hpbar"]
    @sprites["hp"] = sprites["hp"]
    @sprites["expbar"] = sprites["expbar"]
    @sprites["exp"] = sprites["exp"]
    wait(0.1) unless ignore_wait
    endexp = @pokemon.exp
    if @pokemon.level < 100
      endexp = EXP.get_exp(@pokemon.species.leveling_rate(@pokemon.form), @pokemon.level + 1)
    end
    @sprites["vartext"].draw_text(
      {x: 474, y: 46, text: @pokemon.hp.to_s + "/" + @pokemon.totalhp.to_s, color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192), alignment: :right},
      {x: 474, y: 82, text: @pokemon.attack.to_s, color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192), alignment: :right},
      {x: 474, y: 108, text: @pokemon.defense.to_s, color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192), alignment: :right},
      {x: 474, y: 134, text: @pokemon.spatk.to_s, color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192), alignment: :right},
      {x: 474, y: 160, text: @pokemon.spdef.to_s, color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192), alignment: :right},
      {x: 474, y: 186, text: @pokemon.speed.to_s, color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192), alignment: :right},
      {x: 474, y: 212, text: @pokemon.exp.to_s, color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192), alignment: :right},
      {x: 476, y: 238, text: (endexp - @pokemon.exp).to_s, color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192), alignment: :right},
      {x: 148, y: 212, text: "EXP. POINTS", color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192)},
      {x: 148, y: 238, text: "NEXT LV.", color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192)},
      {x: 148, y: 264, text: @pokemon.ability.name, color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192)},
      {x: 20, y: 292, text: @pokemon.ability.description, color: Color.new(64, 64, 64),
       shadow_color: Color.new(216, 216, 192)}
    )
    @page = 2
  end

  def load_page_3(ignore_wait = false)
    @sprites["text"].bitmap.clear
    @sprites["text"].draw_text(
      {x: 8, y: 8, text: "KNOWN MOVES", color: Color.new(248, 248, 248),
       shadow_color: Color.new(96, 96, 96)},
      {x: 8, y: 42, text: symbol(:Lv) + @pokemon.level.to_s, color: Color.new(248, 248, 248),
       shadow_color: Color.new(96, 96, 96)},
      {x: 80, y: 42, text: @pokemon.name, color: Color.new(248, 248, 248),
       shadow_color: Color.new(96, 96, 96)}
    )
    if @pokemon.female?
      gender_text = symbol(:female)
      gender_color = Color.new(248, 184, 112)
      gender_color_shadow = Color.new(224, 8, 8)
    elsif @pokemon.male?
      gender_text = symbol(:male)
      gender_color = Color.new(64, 200, 248)
      gender_color_shadow = Color.new(0, 96, 144)
    end
    if !@pokemon.genderless?
      @sprites["text"].draw_text(
        x: 210, y: 42, text: gender_text, color: gender_color, shadow_color: gender_color_shadow
      )
    end
    @sprites["header"].set_bitmap(@path + "page_3_header")
    newpanel = Sprite.new(@viewport)
    newpanel.set_bitmap(@path + "page_3")
    newpanel.y = 32
    if @page == 2
      @sprites["vartext"].visible = false
      @sprites["hpbar"].dispose
      @sprites["hp"].dispose
      @sprites["expbar"].dispose
      @sprites["exp"].dispose
      @sprites["panel"].z = 1
      frames = framecount(0.08)
      increment = Graphics.width / frames.to_f
      for i in 1..frames
        Graphics.update
        Input.update
        update_sprites
        @sprites["panel"].x = increment * i
      end
      @sprites["panel"].dispose
      @sprites["vartext"].bitmap.clear
      @sprites["vartext"].visible = true
    elsif @page == 4
      @sprites["move_panel"].dispose if @sprites["move_panel"]
      if @sprites["shiny"]
        @sprites["shiny"].x = 204
        @sprites["shiny"].y = 72
      end
      @sprites["movetext"].dispose
      @sprites["panel"].dispose
      @sprites["type1"].dispose
      @sprites["type2"].dispose if @sprites["type2"]
      @sprites["icon"].dispose
      @sprites["selector"].dispose
      @sprites["ball"].visible = true
      @sprites["pokemon"].visible = true
      @sprites["status"].visible = true
      @sprites["vartext"].bitmap.clear
    end
    @sprites["panel"] = newpanel
    if @page == 2
      wait(0.1) unless ignore_wait
    end
    draw_move_panels
    @page = 3
  end

  def draw_move_panels
    @sprites["vartext"].bitmap.clear
    for i in 0...4
      move = @pokemon.moves[i]
      @sprites["type_#{i}"].dispose if @sprites["type_#{i}"]
      if move
        @sprites["type_#{i}"] = TypeIcon.new(move.type, @viewport)
        @sprites["type_#{i}"].x = 246
        @sprites["type_#{i}"].y = 42 + 56 * i
        @sprites["vartext"].draw_text(
          {x: 326, y: 48 + 56 * i, text: move.name, color: Color.new(32, 32, 32),
           shadow_color: Color.new(216, 216, 216)},
          {x: 436, y: 70 + 56 * i, text: move.pp.to_s, color: Color.new(32, 32, 32),
           shadow_color: Color.new(216, 216, 216), alignment: :right},
          {x: 436, y: 70 + 56 * i, text: "/", color: Color.new(32, 32, 32),
           shadow_color: Color.new(216, 216, 216)},
          {x: 472, y: 70 + 56 * i, text: move.totalpp.to_s, color: Color.new(32, 32, 32),
           shadow_color: Color.new(216, 216, 216), alignment: :right},
          {x: 392, y: 70 + 56 * i, text: "PP", color: Color.new(32, 32, 32),
           shadow_color: Color.new(216, 216, 216), small: true}
        )
      else
        @sprites["vartext"].draw_text(
          {x: 326, y: 48 + 56 * i, text: "-", color: Color.new(32, 32, 32),
           shadow_color: Color.new(216, 216, 216)},
          {x: 392, y: 70 + 56 * i, text: "PP", color: Color.new(32, 32, 32),
           shadow_color: Color.new(216, 216, 216), small: true},
          {x: 410, y: 70 + 56 * i, text: "--", color: Color.new(32, 32, 32),
           shadow_color: Color.new(216, 216, 216), small: true}
        )
      end
    end
  end

  def load_page_3_details
    @sprites["panel"].set_bitmap(@path + "page_3_details")
    @sprites["move_panel"] = Sprite.new(@viewport)
    suffix = @pokemon.shiny? ? "_shiny" : ""
    @sprites["move_panel"].set_bitmap(@path + "move_panel" + suffix)
    @sprites["move_panel"].x = 4
    @sprites["move_panel"].y = 36
    @sprites["header"].set_bitmap(@path + "page_3_details_header")
    @sprites["text"].bitmap.clear
    @sprites["text"].draw_text(
      {x: 8, y: 8, text: "KNOWN MOVES", color: Color.new(248, 248, 248),
       shadow_color: Color.new(96, 96, 96)},
      {x: 80, y: 42, text: @pokemon.name, color: Color.new(248, 248, 248),
       shadow_color: Color.new(96, 96, 96)}
    )
    if @pokemon.female?
      gender_text = symbol(:female)
      gender_color = Color.new(248, 184, 112)
      gender_color_shadow = Color.new(224, 8, 8)
    elsif @pokemon.male?
      gender_text = symbol(:male)
      gender_color = Color.new(64, 200, 248)
      gender_color_shadow = Color.new(0, 96, 144)
    end
    if !@pokemon.genderless?
      @sprites["text"].draw_text(
        x: 210, y: 42, text: gender_text, color: gender_color, shadow_color: gender_color_shadow
      )
    end
    if @sprites["shiny"]
      @sprites["shiny"].x = 8
      @sprites["shiny"].y = 40
    end
    @sprites["ball"].visible = false
    @sprites["pokemon"].visible = false
    @sprites["status"].visible = false
    @sprites["icon"] = PokemonIcon.new(@pokemon, @viewport)
    @sprites["icon"].set_frame(1)
    @sprites["icon"].x = 48
    @sprites["icon"].y = 32
    @sprites["icon"].z = 1
    @sprites["icon"].mirror = true
    @sprites["type1"] = TypeIcon.new(@pokemon.type1, @viewport)
    @sprites["type1"].x = 96
    @sprites["type1"].y = 70
    if @pokemon.type2
      @sprites["type2"] = TypeIcon.new(@pokemon.type2, @viewport)
      @sprites["type2"].x = 168
      @sprites["type2"].y = 70
    end
    @sprites["selector"] = Sprite.new(@viewport)
    @sprites["selector"].set_bitmap(@path + "selector")
    @sprites["selector"].x = 240
    @sprites["selector"].y = 36
    @sprites["selector"].z = 1
    @sprites["vartext"].draw_text(
      x: 326, y: 272, text: "CANCEL", color: Color.new(32, 32, 32),
      shadow_color: Color.new(216, 216, 216)
    )
    @sprites["movetext"] = Sprite.new(@viewport)
    @sprites["movetext"].set_bitmap(Graphics.width, Graphics.height)
    @sprites["movetext"].z = 1
    @move_index = 0
    @page = 4
    update_move_text
  end

  def update_move_text
    @sprites["movetext"].bitmap.clear
    idx = @move_index == -1 ? 4 : @move_index
    @sprites["selector"].y = 36 + idx * 56
    if @move_index > -1
      power = @pokemon.moves[@move_index].power
      power = "---" if power == 0
      accuracy = @pokemon.moves[@move_index].accuracy
      accuracy = "---" if accuracy == 0
      @sprites["movetext"].bitmap.clear
      @sprites["movetext"].draw_text(
        {x: 150, y: 120, text: power.to_s, color: Color.new(64, 64, 64),
         shadow_color: Color.new(216, 216, 192), alignment: :right},
        {x: 150, y: 148, text: accuracy.to_s, color: Color.new(64, 64, 64),
         shadow_color: Color.new(216, 216, 192), alignment: :right}
      )
      lines = MessageWindow.get_formatted_text(@sprites["movetext"].bitmap, 214,
          @pokemon.moves[@move_index].description).split("\n")
      lines.each_with_index do |e, i|
        @sprites["movetext"].draw_text(
          {x: 14, y: 202 + 28 * i, text: e, color: Color.new(64, 64, 64),
           shadow_color: Color.new(216, 216, 192)}
        )
      end
    end
  end

  def swap_move
    if @swapping_move
      @pokemon.moves.swap!(@swapping_move, @move_index)
      stop_swap_move
      draw_move_panels
      @sprites["vartext"].draw_text(
        x: 326, y: 272, text: "CANCEL", color: Color.new(32, 32, 32),
        shadow_color: Color.new(216, 216, 216)
      )
    else
      @swapping_move = @move_index
      @sprites["selector_blue"] = Sprite.new(@viewport)
      @sprites["selector_blue"].set_bitmap(@path + "selector_blue")
      @sprites["selector_blue"].x = @sprites["selector"].x
      @sprites["selector_blue"].y = @sprites["selector"].y
      @j = 0
    end
  end

  def stop_swap_move
    @swapping_move = nil
    @j = nil
    @sprites["selector_blue"].dispose
    @sprites["selector"].visible = true
  end

  def update_sprites
    if @page == 4
      super(no_update: ["icon"])
      if @j # Swapping move
        @j += 1
        if @j % framecount(0.25) == 0
          @sprites["selector"].visible = !@sprites["selector"].visible
        end
      end
    else
      super()
    end
    # Initial bounce animation
    @i += 1 if @i
    if @i && @i >= 0
      if @i < framecount(0.05)
        @sprites["pokemon"].y -= 2 * @amplitude
      elsif @i < framecount(0.1)
        @sprites["pokemon"].y -= @amplitude
      elsif @i < framecount(0.125)
      elsif @i < framecount(0.15)
        @sprites["pokemon"].y += @amplitude
      elsif @i < framecount(0.2)
        @sprites["pokemon"].y += 2 * @amplitude
      elsif @i < framecount(0.225)
        @sprites["pokemon"].y += @amplitude
      elsif @i < framecount(0.25)
        @sprites["pokemon"].y -= @amplitude
      elsif @i < framecount(0.275)
        @sprites["pokemon"].y -= 2 * @amplitude
      elsif @i < framecount(0.3)
        @sprites["pokemon"].y -= @amplitude
      elsif @i < framecount(0.325)
      elsif @i < framecount(0.42)
        @sprites["pokemon"].y += @amplitude
      else
        @sprites["pokemon"].y = 66
        @i = nil
      end
    end
  end

  def update
    super
    if Input.right? && (@page == 1 || @page == 2)
      Audio.se_play("audio/se/menu_select")
      if @page == 1
        load_page_2
      elsif @page == 2
        load_page_3
      end
    end
    if Input.left? && (@page == 2 || @page == 3)
      Audio.se_play("audio/se/menu_select")
      if @page == 2
        load_page_1
      elsif @page == 3
        load_page_2
      end
    end
    if Input.confirm? && (@page == 1 || @page == 3 || @page == 4)
      Audio.se_play("audio/se/menu_select")
      if @page == 1
        stop
      elsif @page == 3
        load_page_3_details
      elsif @page == 4
        if @move_index == -1 # Cancel
          load_page_3
        else
          swap_move
        end
      end
    end
    if Input.down?
      if @page == 4
        @move_index += 1
        if !@pokemon.moves[@move_index]
          if @swapping_move
            @move_index = 0
          else
            @move_index = -1
          end
        end
        Audio.se_play("audio/se/menu_select")
        update_move_text
      else
        if @party_index < @party.size - 1
          change_pokemon(@party_index + 1)
        end
      end
    end
    if Input.up?
      if @page == 4
        if @move_index == -1
          @move_index = @pokemon.moves.size - 1
        else
          @move_index -= 1
        end
        if @move_index == -1 && @swapping_move
          @move_index = @pokemon.moves.size - 1
        end
        Audio.se_play("audio/se/menu_select")
        update_move_text
      else
        if @party_index > 0
          change_pokemon(@party_index - 1)
        end
      end
    end
    if Input.cancel?
      if @page == 4
        if @swapping_move
          Audio.se_play("audio/se/menu_select")
          stop_swap_move
        else
          load_page_3
        end
      else
        Audio.se_play("audio/se/menu_select")
        stop
      end
    end
  end

  def stop
    if @party_ui
      @party_ui.sprites["panel_#{@party_ui.index}"].deselect
      @party_ui.index = @party_index
      @party_ui.sprites["panel_#{@party_index}"].select
    end
    super
  end
end
