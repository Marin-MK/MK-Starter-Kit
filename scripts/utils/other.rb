def get_direction(dir)
  return 2 if dir == :down
  return 4 if dir == :left
  return 6 if dir == :right
  return 8 if dir == :up
end