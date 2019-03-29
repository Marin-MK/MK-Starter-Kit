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

  def initialize
    super("pause_menu")
    $trainer.give_pokedex
    @sprites["desc_bar"] = Sprite.new(@viewport)
    @sprites["desc_bar"].set_bitmap(@path + "desc_bar")
    @sprites["desc_bar"].y = 240
    @choices = []
    @choices << "POKéDEX" if $trainer.pokedex.visible?
    @choices << "POKéMON" if $trainer.party.size > 0
    @choices = @choices.concat(["BAG", $trainer.name, "SAVE", "OPTION", "EXIT"])
    @commands = ChoiceWindow.new(
        choices: @choices,
        x: 338,
        y: 2,
        cancel_choice: -1,
        visible_choices: 7,
        width: 140,
        viewport: @viewport
    )
    @oldindex = 0
    @sprites["desc"] = MessageWindow.new(
      text: Descriptions[@choices[0]],
      x: 4,
      y: 254,
      width: 472,
      height: 64,
      windowskin: 0,
      viewport: @viewport,
      color: Color.new(248, 248, 248),
      shadow_color: Color.new(96, 96, 96),
      letter_by_letter: false
    )
  end

  def update
    super
    if @oldindex != @commands.index
      c = @choices[@commands.index]
      c = "NAME" if c == $trainer.name
      @sprites["desc"].text = Descriptions[c]
      @sprites["desc"].update
    end
    @oldindex = @commands.index
    cmd = @commands.update
    if cmd
      if cmd == -1
        stop
        return
      end
      case @choices[cmd]
      when "POKéDEX"
        show_message("Open Pokedex")
      when "POKéMON"
        show_message("Open Party")
      when "BAG"
        show_message("Open Bag")
      when $trainer.name
        $game.start_ui(TrainerCardUI)
      when "SAVE"
        show_message("Open Save Menu")
      when "OPTION"
        show_message("Options Menu")
      when "EXIT"
        Kernel.abort
      end
    end
  end

  def update_sprites
    super
    $visuals.update(:no_events)
  end
end
