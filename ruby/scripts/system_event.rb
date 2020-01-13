class SystemEvent
  Events = {}

  def self.trigger(event, *args)
    if Events[event]
      Events[event].call(*args)
    else
      raise "No SystemEvent could be found with identifier #{event.inspect}"
    end
  end

  def self.register(event, code)
    Events[event] = code
  end
end

SystemEvent.register(:taking_step, proc do |oldx, oldy, oldmapid, newx, newy, newmapid|

end)

SystemEvent.register(:taken_step, proc do |x, y|
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
end)
