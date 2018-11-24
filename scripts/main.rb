loop do
  Input.update
  $game.update
  $visuals.update
  if Input.trigger?(Input::CTRL)
    abort
  end
  Graphics.update
end

# TODO:
# - Make switching event states cancel any planned moveroutes