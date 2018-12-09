# Inherit on a class to allow Class.Constant besides Class::Constant.
class Enum
  class << self
    def method_missing(name)
      return const_get(name)
    end
  end
end

# Ensures #msgbox always pops up a box, no matter the RGSS version
unless defined?(msgbox) == "method"
	def msgbox(*args)
		p *args
	end
end

# Returns the coordinates of the facing tile based on x,y,direction.
# @param x [Fixnum] the current X value.
# @param y [Fixnum] the current Y value.
# @param direction [Fixnum, Symbol] the facing direction.
# @return [Array] [x,y] the coordinates of the facing tile based on x, y, direction.
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

class Sprite
  # Empty hash that can be used to store some data on a sprite.
  attr_accessor :hash

  alias old_initialize initialize
  def initialize(viewport = nil, hash = {})
    old_initialize(viewport)
    @hash = hash
  end
end
