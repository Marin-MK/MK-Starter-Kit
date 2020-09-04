class PauseMenuUI < BaseUI
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

  def start
    super(path: "pause_menu", fade: false)
    $trainer.give_pokedex
    @sprites["desc"] = Sprite.new(@viewport)
    @sprites["desc"].set_bitmap(@path + "desc_bar")
    @sprites["desc"].y = 240
    choices = []
    choices << "POKéDEX" if $trainer.has_pokedex?
    choices << "POKéMON" if $trainer.party.size > 0
    choices = choices.concat(["BAG", $trainer.name, "SAVE", "OPTION", "EXIT"])
    @cmdwin = ChoiceWindow.new(
        choices: choices,
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
    text = Descriptions[@cmdwin.choices[idx].gsub($trainer.name, "NAME")]
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
    test_disposed
    loop do
      choice = @cmdwin.get_choice do |oldidx, newidx|
        if oldidx != newidx
          draw_description(newidx)
          $temp.last_menu_index = newidx
        end
        update_sprites
        if Input.start?
          stop
          return
        end
      end
      case choice
      when "POKéDEX"

      when "POKéMON"
        PartyUI.start
      when "BAG"
        BagUI.start
      when $trainer.name
        TrainerCardUI.start
      when "SAVE"
        hide_ui
        ret = SaveUI.start
        if ret # Saved
          break
        else
          show_ui
        end
      when "OPTION"
        OptionsUI.start(self)
      when "EXIT"
        break
      end
    end
    stop
  end

  def show_ui
    @sprites.each_value { |e| e.visible = true }
    @cmdwin.visible = true
  end

  def hide_ui
    @sprites.each_value { |e| e.visible = false }
    @cmdwin.visible = false
  end

  def update_sprites
    super
    $visuals.update(:no_events)
  end

  def dispose
    test_disposed
    @cmdwin.dispose
    super
  end
end
