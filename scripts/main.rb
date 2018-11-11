loop do
  Input.update
  $game.update
  $visuals.update
  if Input.trigger?(Input::CTRL)
    abort
  end
  Graphics.update
end

=begin

- Events can now be in an inactive/nil state. This is when none of the states' conditions are true.

=end