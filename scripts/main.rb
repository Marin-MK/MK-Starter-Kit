# Starts the main game loop required to keep the game running.

loop do
  Input.update
  $game.update
  $visuals.update
  if Input.trigger?(Input::CTRL)
    abort
  end
  Graphics.update
end