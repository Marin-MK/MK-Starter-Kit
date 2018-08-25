=begin

START
$game is initialized
$game.player is initialized and in turn initializes $visuals.player, which displays the graphics on screen
$game.map is initialized and in turn initializes $visuals.map, which displays the graphics on screen

LOOP
$game is updated
$game.player is updated
$visuals is updated
$visuals.map is updated

(map will be updated too once there's something worth updating there)

=end
i = 1
loop do
  Graphics.update
  Input.update
  $game.update
  $visuals.update
end