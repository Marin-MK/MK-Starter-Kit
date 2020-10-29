class PauseMenuUI
  Descriptions = {
    "POKéDEX" => "A device that records POKéMON secrets upon meeting or catching them.",
    "POKéMON" => "Check and organise POKéMON that are traveling with you in your party.",
    "BAG" => "Equipped with pockets for storing items you bought, received, or found.",
    "NAME" => "Check your money and other game data.",
    "SAVE" => "Save your game with a complete record of your progress to take a break.",
    "OPTION" => "Adjust various game settings such as text speed, game rules, etc.",
    "EXIT" => "Close this MENU window."
  }

  attr_reader :cmdwin
  attr_reader :sprites

  def get_commands
    commands = []
    commands << "POKéDEX" if $trainer.has_pokedex?
    commands << "POKéMON" if $trainer.party.size > 0
    commands << "BAG"
    commands << $trainer.name
    commands << "SAVE"
    commands << "OPTION"
    commands << "EXIT"
    return commands
  end

  def initialize
    @path = "gfx/ui/pause_menu/"
    @viewport = Viewport.new(0, 0, System.width, System.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["desc"] = Sprite.new(@viewport)
    @sprites["desc"].set_bitmap(@path + "desc_bar")
    @sprites["desc"].y = 240
    @cmdwin = ChoiceWindow.new(
        choices: get_commands,
        x: System.width,
        ox: :right,
        line_y_start: -4,
        line_y_space: -2,
        width: 144,
        viewport: @viewport,
        initial_choice: $temp.last_menu_index
    )
    @sprites["text"] = Sprite.new(@viewport)
    @sprites["text"].set_bitmap(System.width, System.height)
    @sprites["text"].z = 1
    @sprites["text"].visible = $trainer.options.button_mode == :HELP
    @sprites["desc"].visible = $trainer.options.button_mode == :HELP
    draw_description($temp.last_menu_index)
    Audio.se_play("audio/se/menu_open")
  end

  def draw_description(idx)
    @sprites["text"].bitmap.clear
    command = @cmdwin.choices[idx]
    command = "NAME" if command == $trainer.name
    text = Descriptions[command]
    text ||= "No description."
    description = MessageWindow.get_formatted_text(@sprites["text"].bitmap, 460, text).split("\n")
    description.each_with_index do |txt, i|
      @sprites["text"].draw_text(
        x: 4,
        y: 256 + 30 * i,
        text: txt,
        color: Color::LIGHTBASE,
        shadow_color: Color::LIGHTSHADOW
      )
    end
  end

  def main
    loop do
      System.update
      update
      command = @cmdwin.get_choice do |oldidx, newidx|
        if oldidx != newidx
          draw_description(newidx)
          $temp.last_menu_index = newidx
        end
        update
        if Input.start?
          stop
          return
        end
      end
      ret = handle_command(command)
      break if @break
    end
  end

  def handle_command(command)
    case command
    when "POKéDEX"

    when "POKéMON"
      party = PartyUI.new { update }
      party.main
      party.dispose { update }
    when "BAG"
      bag = BagUI.new { update }
      bag.main
      bag.dispose { update }
    when $trainer.name
      card = TrainerCardUI.new { update }
      card.main
      card.dispose { update }
    when "SAVE"
      hide_ui
      ret = SaveUI.start
      if ret # Saved
        stop
      else
        show_ui
      end
    when "OPTION"
      OptionsUI.start(self)
    when "EXIT"
      stop
    end
  end

  def show_ui
    @sprites.each_value { |e| e.visible = true }
    @cmdwin.visible = true
  end

  def hide_ui
    @sprites.each_value { |e| e.visible = false }
    @cmdwin.visible = false
  end

  def update
    $visuals.update(:no_events)
  end

  def stop
    @break = true
  end

  def dispose
    stop
    @sprites.each_value(&:dispose)
    @cmdwin.dispose
    @viewport.dispose
  end
end
