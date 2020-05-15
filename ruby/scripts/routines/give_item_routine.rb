class GiveItemRoutine
  attr_accessor :itemwin

  def initialize(ui)
    if ui.is_a?(PartyUI)
      @party_ui = ui
      @bag_ui = BagUI.start_choose_item
      @initializer = :party
    end
    if ui.is_a?(BagUI)
      @bag_ui = ui
      @party_ui = PartyUI.start_give_item
      @initializer = :bag
    end
    @msgwin = MessageWindow.new(
      y: 224,
      z: 3,
      width: 480,
      height: 96,
      windowskin: :choice,
      line_x_start: -16,
      line_y_space: -2,
      line_y_start: -2,
      visible: false,
      viewport: @party_ui.viewport,
      update: proc { @party_ui.update_sprites }
    )
  end

  def from_party?
    return @initializer == :party
  end

  def from_bag?
    return @initializer == :bag
  end

  def start
    ret = true
    loop do
      if from_party?
        @pokemon = @party_ui.party[@party_ui.index]
        @item = @bag_ui.choose_item
      elsif from_bag?
        @item = Item.get(@bag_ui.selected_item[:item])
        @pokemon = @party_ui.give_item
      end
      if @item.nil? || @pokemon.nil?
        ret = nil
        break
      elsif @item.pocket == :key_items
        @bag_ui.set_footer(true) if from_party?
        @msgwin.show("The " + item.name + " can't be held.")
        @bag_ui.set_footer(false) if from_party?
      else
        if from_party?
          @itemwin.dispose
          @bag_ui.end_choose_item
        end
        if @pokemon.has_item?
          @msgwin.ending_arrow = true
          @msgwin.show(@pokemon.name + " is already holding\none " + @pokemon.item.name + ".")
          @msgwin.ending_arrow = false
          yes = @msgwin.show_confirm("Would you like to switch the\ntwo items?")
          if yes
            @msgwin.show("The " + @pokemon.item.name + " was taken and\nreplaced with the " + @item.name + ".")
            $trainer.bag.add_item(@pokemon.item)
            $trainer.bag.remove_item(@item)
            @pokemon.item = @item
          end
        else
          @msgwin.show(@pokemon.name + " was given the\n" + @item.name + " to hold.")
          $trainer.bag.remove_item(@item)
          @pokemon.item = @item
          @party_ui.sprites["panel_#{@party_ui.party.index(@pokemon)}"].refresh_item
        end
        break
      end
    end
    return ret
  end

  def stop
    @msgwin.dispose
    if @item && !$trainer.bag.has_item?(@item)
      if $trainer.bag.indexes[@bag_ui.pocket][:top_idx] == 0
        $trainer.bag.indexes[@bag_ui.pocket][:list_idx] -= 1 if $trainer.bag.indexes[@bag_ui.pocket][:list_idx] > 0
      else
        $trainer.bag.indexes[@bag_ui.pocket][:top_idx] -= 1
      end
    end
    if from_bag?
      @bag_ui.draw_pocket(false)
      @party_ui.end_give_item
    end
    if from_party?
      @itemwin.dispose if !@itemwin.disposed?
      @bag_ui.end_choose_item if !@bag_ui.disposed?
    end
  end
end

class BagUI
  def self.start_choose_item
    instance = self.new
    instance.start
    instance.hide_black
    return instance
  end

  def choose_item
    test_disposed
    @choose_item = true
    @ret = nil
    until @stop || @disposed
      Graphics.update
      Input.update
      update_sprites
      update
    end
    @stop = false # Allow it to be reused
    return @ret
  end

  def end_choose_item
    @choose_item = false
    self.dispose
  end

  alias giveitemroutine_stop stop
  def stop
    if @choose_item
      @stop = true
    else
      giveitemroutine_stop
    end
  end

  alias giveitemroutine_select_item select_item
  def select_item
    if @choose_item
      @ret = Item.get(@items[item_idx][:item])
      stop
    else
      giveitemroutine_select_item
    end
  end
end

class PartyUI
  def self.start_give_item
    instance = self.new
    instance.start
    instance.sprites["window"].text = "Give to which POKéMON?"
    instance.hide_black
    return instance
  end

  def give_item
    test_disposed
    @give_item = true
    @ret = nil
    until @stop || @disposed
      Graphics.update
      Input.update
      update_sprites
      update
    end
    @stop = false
    return @ret
  end

  def end_give_item
    @give_item = false
    self.dispose
  end

  alias giveitemroutine_stop stop
  def stop
    if @give_item
      @stop = true
    else
      giveitemroutine_stop
    end
  end

  alias giveitemroutine_select_pokemon select_pokemon
  def select_pokemon
    if @give_pokemon
      Audio.se_play("audio/se/menu_select")
      @ret = @party[@index]
      stop
    else
      giveitemroutine_select_pokemon
    end
  end
end
