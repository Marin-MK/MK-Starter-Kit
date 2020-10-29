class GiveItemRoutine
  def self.possible?(pokemon, item)
    validate \
        pokemon => Pokemon,
        item => [Symbol, Item]
    item = Item.get(item)
    if item.pocket == :key_items
      return false
    end
    return true
  end

  def self.run(pokemon, item, viewport, &block)
    validate \
        pokemon => Pokemon,
        item => [Symbol, Item],
        viewport => [Viewport, NilClass]
    item = Item.get(item)
    msgwin = MessageWindow.new(
      y: 224,
      z: 99999,
      width: 480,
      height: 96,
      windowskin: :choice,
      line_x_start: -16,
      line_y_space: -2,
      line_y_start: -2,
      visible: false,
      viewport: viewport,
      update: proc { block.call if block }
    )
    success = false
    if item.pocket == :key_items
      msgwin.show("The " + item.name + " can't be held.")
    else
      if pokemon.has_item?
        msgwin.ending_arrow = true
        msgwin.show(pokemon.name + " is already holding\none " + pokemon.item.name + ".")
        msgwin.ending_arrow = false
        yes = msgwin.show_confirm("Would you like to switch the\ntwo items?")
        if yes
          msgwin.show("The " + pokemon.item.name + " was taken and\nreplaced with the " + item.name + ".")
          $trainer.bag.add_item(pokemon.item)
          $trainer.bag.remove_item(item)
          pokemon.item = item
          success = true
        end
      else
        msgwin.show(pokemon.name + " was given the\n" + item.name + " to hold.")
        $trainer.bag.remove_item(item)
        pokemon.item = item
        success = true
      end
    end
    msgwin.dispose
    return success
  end
end
