# Inherit on a class to allow Class.Constant besides Class::Constant.
class Enum
  class << self
    def method_missing(name)
      return const_get(name)
    end
  end
end

# Ensure #msgbox always pops up a box, no matter the RGSS version
unless defined?(msgbox) == "method"
	def msgbox(*args)
		p *args
	end
end

# Returns the coordinates of the tile based on an x,y value and the facing direction.
# E.g. facing_coordinates(0, 0, 2) #=> [0, 1]
def facing_coordinates(x, y, direction)
	validate x => Fixnum, y => Fixnum
	direction = validate_direction(direction)
	newx = x
  newy = y
  newx -= 1 if [1, 4, 7].include?(direction)
  newx += 1 if [3, 6, 9].include?(direction)
  newy -= 1 if [7, 8, 9].include?(direction)
  newy += 1 if [1, 2, 3].include?(direction)
  return newx, newy
end