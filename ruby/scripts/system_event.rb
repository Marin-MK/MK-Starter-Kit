class SystemEvent
  Events = {}

  def self.trigger(event, *args)
    validate event => Symbol
    if Events[event]
      if Events[event].is_a?(Array)
        Events[event].each { |e| e.call(*args) }
      else
        Events[event].call(*args)
      end
    else
      raise "No SystemEvent could be found with identifier #{event.inspect}"
    end
  end

  def self.register(event, code)
    validate event => Symbol, code => Proc
    if Events[event].is_a?(Proc)
      Events[event] = [Events[event], code]
    elsif Events[event].is_a?(Array)
      Events[event] << code
    else
      Events[event] = code
    end
  end
end



SystemEvent.register(:taking_step, proc { |oldx, oldy, oldmapid, newx, newy, newmapid|
})

SystemEvent.register(:taken_step, proc { |x, y|
  log :OVERWORLD, "Moved to (#{x},#{y})"
  # Terrain tag
  $game.map.check_terrain_tag
  # Encounter
  for i in 0...$game.map.data.encounter_tables.size
    table = $game.map.data.encounter_tables[i]
    if table.tiles.include?([x, y])
      Encounter.test_table(table)
    end
  end
})

SystemEvent.register(:wild_pokemon_generated, proc { |poke|
  next poke
})

SystemEvent.register(:map_loaded, proc { |map|
})

SystemEvent.register(:map_unloading, proc { |map|
})

SystemEvent.register(:map_entered, proc { |oldmap, newmap|
})
