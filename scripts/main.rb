# Starts the main game loop required to keep the game running.
msgbox Graphics.height
loop do
  Input.update
  $game.update
  $visuals.update
  if Input.trigger?(Input::CTRL)
    abort
  end
  Graphics.update
end