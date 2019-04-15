class BagUI < BaseUI
  def start
    super(path: "bag")
    @suffix = ["_male", "_female"][$trainer.gender]
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].set_bitmap(@path + "background" + @suffix)
    @sprites["bgtext"] = Sprite.new(@viewport)
    @sprites["bgtext"].set_bitmap(Graphics.width, Graphics.height)
    @sprites["bgtext"].z = 1
    @sprites["bag"] = BagSprite.new($trainer.gender, self)
    @sprites["bag"].x = 22
    @sprites["bag"].y = 66
    @sprites["footer"] = SelectableSprite.new(@viewport)
    @sprites["footer"].set_bitmap(@path + "footer")
    @sprites["footer"].y = 224
    @sprites["list"] = Sprite.new(@viewport)
    @sprites["list"].set_bitmap(@path + "item_list")
    @sprites["list"].x = 176
    @sprites["list"].y = 16
    @sprites["text"] = Sprite.new(@viewport)
    @sprites["text"].set_bitmap(288, 190)
    @sprites["text"].x = 176
    @sprites["text"].y = 16
    @sprites["text"].z = 1
    @sprites["icon"] = Sprite.new(@viewport)
    @sprites["icon"].x = 12
    @sprites["icon"].y = 244
    @sprites["icon"].z = 3
    @sprites["arrow_left"] = ArrowSprite.new(:left, @viewport)
    @sprites["arrow_left"].y = 130
    @sprites["arrow_right"] = ArrowSprite.new(:right, @viewport)
    @sprites["arrow_right"].x = 142
    @sprites["arrow_right"].y = 130
    @sprites["arrow_up"] = ArrowSprite.new(:up, @viewport)
    @sprites["arrow_up"].x = 306
    @sprites["arrow_up"].z = 1
    @sprites["arrow_down"] = ArrowSprite.new(:down, @viewport)
    @sprites["arrow_down"].x = 306
    @sprites["arrow_down"].y = 206
    @sprites["selector"] = SelectableSprite.new(@viewport)
    @sprites["selector"].set_bitmap("gfx/misc/choice_arrow")
    @sprites["selector"].x = 180
    @pocket = $trainer.bag.last_pocket
    @items = $trainer.bag.pockets[@pocket]
    if !@items
      @pocket = Trainer::Bag::POCKETS[0]
      @items = $trainer.bag.pockets[@pocket]
    end
    @top_idx = $trainer.bag.indexes[@pocket][:top_idx]
    @list_idx = $trainer.bag.indexes[@pocket][:list_idx]
    @sprites["selector"].y = 8 + 32 * @list_idx
    draw_pocket(false)
    update_sprites
  end

  def pocket_idx
    idx = Trainer::Bag::POCKETS.index(@pocket)
    return idx if idx >= 0
    return 0
  end

  def pocket_name
    return Trainer::Bag::POCKET_NAMES[@pocket] || "?????"
  end

  def draw_list(selection_changed = false)
    @sprites["text"].bitmap.clear
    for i in @top_idx..(@top_idx + 5)
      if @items[i] || @items[i - 1] || i == 0
        if !@items[i]
          name = "CANCEL"
        else
          item = Item.get(@items[i][:item])
          name = item.name
          @sprites["text"].draw_text(
              {x: 222, y: 8 + 32 * (i - @top_idx), text: "x", color: Color.new(96, 96, 96), shadow_color: Color.new(208, 208, 200)},
              {x: 264, y: 10 + 32 * (i - @top_idx), text: @items[i][:count].to_s, color: Color.new(96, 96, 96), shadow_color: Color.new(208, 208, 200),
               small: true, alignment: :right}
          )
        end
        @sprites["text"].draw_text(
          {x: 18, y: 10 + 32 * (i - @top_idx), text: name, color: Color.new(96, 96, 96), shadow_color: Color.new(208, 208, 200)}
        )
      end
    end
    @sprites["selector"].y = 24 + 32 * @list_idx
    $trainer.bag.indexes[@pocket][:top_idx] = @top_idx
    $trainer.bag.indexes[@pocket][:list_idx] = @list_idx
    @sprites["arrow_up"].visible = @top_idx > 0
    @sprites["arrow_down"].visible = @items.size - @top_idx > 5
    draw_item
    if selection_changed
      Audio.se_play("audio/se/bag_item")
      @sprites["bag"].shake
    end
  end

  def draw_item
    @sprites["bgtext"].bitmap.clear
    @sprites["bgtext"].draw_text(
      {x: 88, y: 24, text: pocket_name, color: Color.new(248, 248, 248), shadow_color: Color.new(96, 96, 96),
       alignment: :center}
    )
    filename = @path + "cancel"
    description = ["CLOSE BAG"]
    if @items[item_idx]
      item = Item.get(@items[item_idx][:item])
      filename = "gfx/items/" + item.intname.to_s
      description = MessageWindow.get_formatted_text(@sprites["bgtext"].bitmap, 384, item.description).split("\n")
    end
    description.each_with_index do |txt, i|
      @sprites["bgtext"].draw_text(
        x: 80, y: 236 + 28 * i, text: txt, color: Color.new(248, 248, 248), shadow_color: Color.new(96, 96, 96)
      )
    end
    @sprites["icon"].set_bitmap(filename)
  end

  def draw_pocket(selection_changed = true)
    @items = $trainer.bag.pockets[@pocket]
    @top_idx = $trainer.bag.indexes[@pocket][:top_idx]
    @list_idx = $trainer.bag.indexes[@pocket][:list_idx]
    if !selection_changed
      @sprites["bag"].pocket = pocket_idx
    else
      $trainer.bag.last_pocket = Trainer::Bag::POCKETS[pocket_idx]
      @sprites["bgtext"].visible = false
      @sprites["text"].visible = false
      @sprites["icon"].visible = false
      @sprites["selector"].visible = false
      @sprites["arrow_up"].visible = false
      @sprites["arrow_down"].visible = false
      @sprites["arrow_left"].visible = false
      @sprites["arrow_right"].visible = false
      @sprites["bag"].pocket = -1
      @sprites["list"].src_rect.height = 0
      @sprites["list"].src_rect.y = @sprites["list"].bitmap.height
      @sprites["list"].y += @sprites["list"].bitmap.height
      frames = framecount(0.15)
      increment = @sprites["list"].bitmap.height / frames.to_f
      for i in 1..frames
        Graphics.update
        Input.update
        if i == 2
          Audio.se_play("audio/se/bag_pocket")
        end
        if i == (frames / 2.0).round
          @sprites["bag"].pocket = pocket_idx
        end
        height = increment * i
        @sprites["list"].src_rect.height = height
        @sprites["list"].src_rect.y = @sprites["list"].bitmap.height - height
        @sprites["list"].y = 16 + @sprites["list"].bitmap.height - height
      end
      wait(0.15)
      @sprites["bgtext"].visible = true
      @sprites["text"].visible = true
      @sprites["icon"].visible = true
      @sprites["selector"].visible = true
      @sprites["arrow_up"].visible = true
      @sprites["arrow_down"].visible = true
      update_sprites
    end
    draw_list
    @sprites["arrow_left"].visible = pocket_idx > 0
    @sprites["arrow_right"].visible = pocket_idx < Trainer::Bag::POCKETS.size - 1
  end

  def item_idx
    return @top_idx + @list_idx
  end

  def update
    super
    stop if Input.cancel?
    if Input.confirm?
      if item_idx == @items.size # Cancel
        stop
      else
        show_item_commands
      end
    end
    if Input.repeat_down?(0.5, 0.18)
      if @list_idx == 3 && @items.size - item_idx > 2
        @top_idx += 1
        draw_list(true)
      elsif @items.size - item_idx > 0
        @list_idx += 1
        draw_list(true)
      end
    end
    if Input.repeat_up?(0.5, 0.18)
      if @list_idx == 2 && item_idx > 2
        @top_idx -= 1
        draw_list(true)
      elsif item_idx > 0
        @list_idx -= 1
        draw_list(true)
      end
    end
    if Input.left? && pocket_idx > 0
      @pocket = Trainer::Bag::POCKETS[pocket_idx - 1]
      draw_pocket
    end
    if Input.right? && pocket_idx < Trainer::Bag::POCKETS.size - 1
      @pocket = Trainer::Bag::POCKETS[pocket_idx + 1]
      draw_pocket
    end
  end

  def show_item_commands
    Audio.se_play("audio/se/menu_select")
    @sprites["footer"].select
    @sprites["footer"].z = 2
    @sprites["selector"].select
    @sprites["arrow_up"].visible = false
    @sprites["arrow_down"].visible = false
    @sprites["arrow_left"].visible = false
    @sprites["arrow_right"].visible = false
    item = Item.get(@items[item_idx][:item])
    msgwin = MessageWindow.new(
      x: 84,
      y: 228,
      z: 3,
      width: 248,
      height: 88,
      text: item.name + " is\nselected.",
      viewport: @viewport,
      windowskin: 4,
      color: Color.new(96, 96, 96),
      shadow_color: Color.new(208, 208, 200),
      letter_by_letter: false
    )
    choices = ["USE", "GIVE", "TOSS", "CANCEL"]
    cmdwin = ChoiceWindow.new(
      x: 338,
      y: 318,
      oy: :bottom,
      z: 3,
      width: 140,
      choices: choices,
      viewport: @viewport
    )
    loop do
      cmd = cmdwin.get_choice { update_sprites }
      case cmd
      when "USE"

      when "GIVE"

      when "TOSS"
        cmdwin.visible = false
        msgwin.width = 280
        msgwin.text = "Toss out how many\n" + item.name + "(s)?"
        numwin = NumericChoiceWindow.new(
          x: 370,
          y: 226,
          z: 3,
          max: @items[item_idx][:count],
          viewport: @viewport
        )
        value = numwin.get_choice
        numwin.dispose
        if value > -1
          msgwin.width = 264
          msgwin.text = "Throw away #{value} of this item?"
          confirmwin = ChoiceWindow.new(
            x: 354,
            y: 226,
            z: 3,
            width: 124,
            choices: ["YES", "NO"],
            viewport: @viewport
          )
          toss = confirmwin.get_choice == "YES"
          confirmwin.dispose
          if toss
            msgwin.width = 392
            msgwin.text = "Threw away #{value}\n" + item.name + "(s)."
            show_message(msgwin, :no_dispose)
            $trainer.bag.remove_item(item, value)
            draw_list
          end
        end
        break
      when "CANCEL"
        break
      end
    end
    @sprites["footer"].deselect
    @sprites["footer"].z = 0
    @sprites["selector"].deselect
    cmdwin.dispose
    msgwin.dispose
  end

  def stop
    if !stopped?
      Audio.se_play("audio/se/menu_select")
    end
    super
  end

  def show_black(mode = nil)
    if mode == :opening || mode == :closing
      super(mode)
    else
      black = Sprite.new(@viewport)
      black.set_bitmap(Graphics.width, Graphics.height)
      black.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
      black.opacity = 0
      black.z = 99999
      sliding = Sprite.new(@viewport)
      sliding.set_bitmap(Graphics.width, Graphics.height)
      sliding.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
      sliding.src_rect.height = 0
      sliding.z = 99999
      frames = framecount(0.15)
      increment_opacity = 255.0 / frames
      increment_height = Graphics.height / frames.to_f
      for i in 1..frames
        Graphics.update
        Input.update
        update_sprites
        sliding.src_rect.height = increment_height * i
        black.opacity = increment_opacity * i
      end
      black.dispose
      sliding.dispose
      Graphics.brightness = 0
    end
  end

  def hide_black(mode = nil)
    if mode == :opening || mode == :closing
      super(mode)
    else
      black = Sprite.new(@viewport)
      black.set_bitmap(Graphics.width, Graphics.height)
      black.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
      black.z = 99999
      sliding = Sprite.new(@viewport)
      sliding.set_bitmap(Graphics.width, Graphics.height)
      sliding.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
      sliding.z = 99999
      frames = framecount(0.15)
      increment_opacity = 255.0 / frames
      increment_height = Graphics.height / frames.to_f
      Graphics.brightness = 255
      for i in 1..frames
        Graphics.update
        Input.update
        update_sprites
        sliding.src_rect.height = Graphics.height - increment_height * i
        black.opacity = 255 - increment_opacity * i
      end
      black.dispose
      sliding.dispose
    end
  end



  class BagSprite < Sprite
    def initialize(gender, ui)
      @gender = gender
      @ui = ui
      super(@ui.viewport)
      pocket = $trainer.bag.last_pocket
      @suffix = ["_male", "_female"][$trainer.gender]
      self.set_bitmap(@ui.path + "bag" + @suffix)
      self.src_rect.width = self.bitmap.width / (Trainer::Bag::POCKETS.size + 1)
      self.ox = self.bitmap.width / 8
      self.oy = self.bitmap.height / 2
      self.z = 2
      @shadow = Sprite.new(@ui.viewport)
      @shadow.set_bitmap(@ui.path + "bag_shadow")
      @shadow.y = 96
      @shadow.z = 1
      pidx = Trainer::Bag::POCKETS.index(pocket)
      pidx = 0 if pidx < 1
      self.src_rect.x = self.src_rect.width * (pidx + 1)
    end

    def pocket=(value)
      self.src_rect.x = self.src_rect.width * (value + 1)
    end

    def x=(value)
      super(value + self.ox)
      @shadow.x = value
    end

    def y=(value)
      super(value + self.oy)
      @shadow.y = value + 96
    end

    def shake
      @i = 0
      self.angle = -2
    end

    def update
      super
      if @i
        @i += 1
        # One angle change takes 0.064 seconds and it can be interrupted.
        case @i
        when framecount(0.064 * 1)
          self.angle = 0
        when framecount(0.064 * 2)
          self.angle = 2
        when framecount(0.064 * 3)
          self.angle = -6
        when framecount(0.064 * 4)
          self.angle = 0
          @i = nil
        end
      end
    end
  end
end
