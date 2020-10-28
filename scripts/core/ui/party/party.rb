class PartyUI
  attr_reader :party
  attr_reader :switching
  attr_reader :viewport
  attr_reader :path
  attr_accessor :index

  def initialize(party = $trainer.party, mode = :default, helptext = nil)
    validate_array party => Pokemon
    validate helptext => [String, NilClass]
    raise "Party is empty!" if party.size == 0
    System.show_overlay { yield if block_given? }
    @party = party
    @mode = mode
    @helptext = helptext || "Choose a POKéMON."
    @path = "gfx/ui/party/"
    @viewport = Viewport.new(0, 0, System.width, System.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].set_bitmap(@path + "background")
    @sprites["window"] = MessageWindow.new(
      y: 256,
      viewport: @viewport,
      width: 368,
      height: 64,
      text: @helptext,
      color: Color::GREYBASE,
      shadow_color: Color::GREYSHADOW,
      letter_by_letter: false,
      windowskin: :helper
    )
    @sprites["cancel"] = SelectableSprite.new(@viewport)
    @sprites["cancel"].set_bitmap(@path + "cancel")
    @sprites["cancel"].x = 368
    @sprites["cancel"].y = 264
    @sprites["panel_0"] = BigPanel.new(self, @party[0])
    @sprites["panel_0"].x = 4
    @sprites["panel_0"].y = 36
    for i in 1...6
      if @party[i]
        @sprites["panel_#{i}"] = Panel.new(self, @party[i])
      else
        @sprites["panel_#{i}"] = Sprite.new(@viewport)
        @sprites["panel_#{i}"].set_bitmap(@path + "panel_empty")
      end
      @sprites["panel_#{i}"].x = 176
      @sprites["panel_#{i}"].y = 18 + 48 * (i - 1)
    end
    @index = 0
    @sprites["panel_0"].select
    System.hide_overlay { update }
  end

  def main
    loop do
      System.update
      update
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
      if Input.cancel?
        if @switching
          stop_switching
        else
          @index = -1
          Audio.se_play("audio/se/menu_select")
          stop
        end
      end
      if Input.confirm?
        if @index == -1 # Cancel
          Audio.se_play("audio/se/menu_select")
          if @switching
            stop_switching
          else
            @index = -1
            stop
          end
        else # A Pokemon
          if @switching
            switch_pokemon
          else
            press_pokemon
          end
        end
      end
      break if @break
    end
  end

  def update
    @sprites["window"].update
    for i in 0...6
      @sprites["panel_#{i}"].update
    end
  end

  def press_pokemon_commands
    return ["SUMMARY", "SWITCH", "ITEM", "CANCEL"]
  end

  def press_pokemon
    if @mode == :choose_pokemon
      stop
      return
    end
    Audio.se_play("audio/se/menu_select")
    pokemon = @party[@index]
    cmdwin = ChoiceWindow.new(
      x: System.width,
      ox: :right,
      y: System.height,
      oy: :bottom,
      z: 1,
      width: 192,
      choices: press_pokemon_commands,
      viewport: @viewport
    )
    @sprites["window"].width = 288
    @sprites["window"].text = "Do what with this " + symbol(:pkmn) + "?"
    loop do
      cmd = cmdwin.get_choice { update }
      ret = handle_command(cmd, cmdwin)
      break if ret == :break
      return if ret == :return
    end
    cmdwin.dispose
    @sprites["window"].width = 368
    @sprites["window"].text = @helptext
  end

  def handle_command(cmd, cmdwin)
    case cmd
    when "SHIFT"
      @return_value = @index
      return :break
    when "SUMMARY"
      summary = SummaryUI.new(@party, @index) { update }
      summary.main
      summary.dispose { update }
    when "SWITCH"
      start_switching
      cmdwin.dispose
      return :return
    when "ITEM"
      cmdwin.visible = false
      ret = press_item
      if ret == :return
        # Quit command menu
        return :return
      else
        cmdwin.visible = true
        cmdwin.set_index(0, false)
        @sprites["window"].width = 288
        @sprites["window"].text = "Do what with this " + symbol(:pkmn) + "?"
      end
    when "CANCEL" # Quit command window
      return :break
    end
    return nil
  end

  def press_item_commands
    return ["GIVE", "TAKE", "CANCEL"]
  end

  def press_item
    itemwin = ChoiceWindow.new(
      x: System.width,
      ox: :right,
      y: System.height,
      oy: :bottom,
      z: 1,
      width: 144,
      choices: press_item_commands,
      viewport: @viewport
    )
    @sprites["window"].width = 336
    @sprites["window"].text = "Do what with an item?"
    choice = itemwin.get_choice { update }
    ret = handle_item_command(choice, itemwin)
    return :return if ret == :return
  end

  def handle_item_command(choice, itemwin)
    case choice
    when "GIVE"
      ret = give_item(itemwin)
      itemwin.dispose
      return :return if ret
    when "TAKE"
      take_item(itemwin)
      itemwin.dispose
      return :return
    else # Cancel
      itemwin.dispose
    end
  end

  def give_item(cmdwin = nil, itemwin = nil)
    routine = GiveItemRoutine.new(self)
    routine.itemwin = itemwin
    ret = routine.start
    @sprites["window"].visible = true
    itemwin.dispose if itemwin && !itemwin.disposed?
    if ret.nil?
      @sprites["window"].width = 288
      @sprites["window"].text = "Do what with this " + symbol(:pkmn) + "?"
      cmdwin.visible = true
      cmdwin.set_index(0, false)
    else
      cmdwin.dispose if cmdwin
      @sprites["window"].width = 368
      @sprites["window"].text = @helptext
    end
    routine.stop
    return ret
  end

  def take_item(itemwin = nil)
    pokemon = @party[@index]
    @sprites["window"].visible = false
    itemwin.visible = false if itemwin
    text = ""
    if pokemon.has_item?
      text = "Received the " + pokemon.item.name + "\nfrom " + pokemon.name + "."
      $trainer.bag.add_item(pokemon.item)
      pokemon.item = nil
    else
      text = pokemon.name + " isn't holding\nanything."
    end
    msgwin = MessageWindow.new(
      y: 224,
      z: 3,
      width: 480,
      height: 96,
      text: text,
      color: Color::GREYBASE,
      shadow_color: Color::GREYSHADOW,
      windowskin: :choice,
      line_x_start: -16,
      line_y_space: -2,
      line_y_start: -2,
      viewport: @viewport,
      update: proc { update }
    )
    msgwin.show
    msgwin.dispose
    @sprites["panel_#{@index}"].refresh_item
  end

  def start_switching
    @switching = @index
    @sprites["panel_#{@index}"].switching = true
    @sprites["window"].width = 368
    @sprites["window"].text = "Move to where?"
  end

  def switch_pokemon
    Audio.se_play("audio/se/menu_select")
    idx1 = @switching
    idx2 = @index
    @sprites["panel_#{idx2}"].deselect
    @sprites["panel_#{idx2}"].switching = true
    mod1 = idx1 == 0 ? -1 : 1
    mod2 = idx2 == 0 ? -1 : 1
    frames = framecount(0.2)
    for i in 1..frames
      System.update
      update
      @sprites["panel_#{idx1}"].x += 320.0 / frames * mod1
      @sprites["panel_#{idx2}"].x += 320.0 / frames * mod2
    end
    wait(0.3) { update }
    @party.swap!(idx1, idx2)
    ns1 = (idx1 == 0 ? BigPanel : Panel).new(self, @party[idx1])
    ns1.x = @sprites["panel_#{idx1}"].x
    ns1.y = @sprites["panel_#{idx1}"].y
    ns1.switching = true
    @sprites["panel_#{idx1}"].dispose
    @sprites["panel_#{idx1}"] = ns1
    ns2 = (idx2 == 0 ? BigPanel : Panel).new(self, @party[idx2])
    ns2.x = @sprites["panel_#{idx2}"].x
    ns2.y = @sprites["panel_#{idx2}"].y
    ns2.switching = true
    @sprites["panel_#{idx2}"].dispose
    @sprites["panel_#{idx2}"] = ns2
    sx1 = ns1.x
    sx2 = ns2.x
    for i in 1..frames
      System.update
      update
      @sprites["panel_#{idx1}"].x -= 320.0 / frames * mod1
      @sprites["panel_#{idx2}"].x -= 320.0 / frames * mod2
    end
    @sprites["panel_#{idx2}"].select
    stop_switching
  end

  def stop_switching
    @switching = nil
    for i in 0...@party.size
      @sprites["panel_#{i}"].switching = false
    end
    @sprites["window"].text = @helptext
  end

  def restart
    @break = false
  end

  def stop
    @break = true
  end

  def dispose
    System.show_overlay { update }
    stop
    @sprites.each_value(&:dispose)
    @viewport.dispose
    System.hide_overlay { yield if block_given? }
  end
end
