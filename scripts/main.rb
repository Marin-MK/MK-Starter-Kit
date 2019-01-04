# Starts the main game loop required to keep the game running.

loop do
  Input.update
  $game.update
  $visuals.update
  if Input.trigger?(Input::CTRL)
    #t = $visuals.map_renderer.player_tile
    #msgbox [$game.player.x, $game.player.y].inspect + "\n" + [t.mapx, t.mapy].inspect
    #msgbox $visuals.maps[2].real_x
    abort
  end
  #unless $visuals.map_renderer.empty?
  #  str = ""
  #  a = $visuals.map_renderer.array[Visuals::MapRenderer::XSIZE * 4...Visuals::MapRenderer::XSIZE * 5]
  #  for i in 0...a.size
  #    if a[i].sprites[0].x != a[0].sprites[0].x + 32 * i
  #      i = 0
  #      for i in 0...a.size
  #        puts i.to_digits(2) + ": " + a[i].sprites[0].x.to_s + "     " + a[i].real_x.to_s
  #      end
  #      puts "\n\n"
  #      break
  #    end
  #  end
  #end
  Graphics.update
end
