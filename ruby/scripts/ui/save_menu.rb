class SaveUI < BaseUI
  def start
    super(fade: false)
    @sprites["details"] = SplitSprite.new(@viewport)
    @sprites["details"].set(Windowskin.get(:helper))
    @sprites["details"].width = 248
    @sprites["details"].height = 168
    @sprites["details"].x = 4
    @sprites["details"].y = 4
    @sprites["details"].refresh
    @sprites["text"] = Sprite.new(@viewport)
    @sprites["text"].set_bitmap(248, 168)
    @sprites["text"].x = 4
    @sprites["text"].y = 4
    @sprites["text"].draw_text(
      {x: 124, y: 18, text: "PEWTER CITY", color: Color.new(48, 80, 200),#$game.map.name
       shadow_color: Color.new(160, 192, 240), alignment: :center},
      {x: 16, y: 46, text: "PLAYER", color: Color.new(96, 96, 96),
       shadow_color: Color.new(208, 208, 200), small: true},
      {x: 132, y: 46, text: $trainer.name, color: Color.new(96, 96, 96),
       shadow_color: Color.new(208, 208, 200)},
      {x: 16, y: 74, text: "BADGES", color: Color.new(96, 96, 96),
       shadow_color: Color.new(208, 208, 200), small: true},
      {x: 130, y: 74, text: $trainer.badge_count.to_s, color: Color.new(96, 96, 96),
       shadow_color: Color.new(208, 208, 200), small: true},
    )
    hours = (System.frame_count / 60 / 60 / 60 % 60).to_s
    minutes = (System.frame_count / 60 / 60 % 60).to_digits(2)
    if $trainer.has_pokedex?
      @sprites["text"].draw_text(
        {x: 16, y: 102, text: "POKéDEX", color: Color.new(96, 96, 96),
         shadow_color: Color.new(208, 208, 200), small: true},
        {x: 130, y: 102, text: $trainer.pokedex.owned_count.to_s, color: Color.new(96, 96, 96),
         shadow_color: Color.new(208, 208, 200), small: true},
        {x: 16, y: 130, text: "TIME", color: Color.new(96, 96, 96),
         shadow_color: Color.new(208, 208, 200), small: true},
        {x: 130, y: 130, text: hours + ":" + minutes, color: Color.new(96, 96, 96),
         shadow_color: Color.new(208, 208, 200), small: true}
      )
    else
      @sprites["text"].draw_text(
        {x: 16, y: 102, text: "TIME", color: Color.new(96, 96, 96),
         shadow_color: Color.new(208, 208, 200), small: true},
        {x: 130, y: 102, text: hours + ":" + minutes, color: Color.new(96, 96, 96),
         shadow_color: Color.new(208, 208, 200), small: true}
      )
    end
  end

  def update
    if show_confirm("Would you like to save the game?")
      save_exists = true # to implement
      if save_exists
        if show_confirm("There is already a saved file.\nIs it okay to overwrite it?")
          save_message
        else
          @ret = false
        end
      else
        save_message
      end
      stop
    else
      @ret = false
      stop
    end
  end

  def save_message
    show_message("SAVING...\nDON'T TURN OFF THE POWER.")
    Game.save_game
	Audio.se_play("audio/se/save")
    show_message($trainer.name + " saved the game.")
  end

  def update_sprites
    $visuals.update(:no_events)
  end
end
