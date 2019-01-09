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
# @param x [Integer] the current X value.
# @param y [Integer] the current Y value.
# @param direction [Integer, Symbol] the facing direction.
# @return [Array] [x,y] the coordinates of the facing tile based on x, y, direction.
def facing_coordinates(x, y, direction)
	validate x => Integer, y => Integer
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

# @return [Integer] the amount of memory the game is currently using.
def get_memory
  ret = `pmap #{Process.pid} | tail -1`.reverse
  return ret[2...ret.index(' ')].reverse.to_i
end

# Performs a memory and speed test.
# @param abort_after [Boolean] whether or not to shut down after performing the test.
def perform_test(abort_after = true)
  smem = get_memory
  st = Time.now
  yield if block_given?
  et = (Time.now - st).round(4)
  emem = get_memory
  msgbox "Memory Before: #{smem}\nMemory After: #{emem}\nMemory Difference: #{emem > smem ? "+" : emem < smem ? "-" : ""}#{emem - smem}\n----------------------\n" +
      "Time: #{et} seconds"
  abort if abort_after
end

[Object, Symbol, Integer].each do |c|
  c.class_eval do
    alias oldinspect inspect
    def inspect(length = 0)
      v = oldinspect
      return v if length < 1
      return v if v.size <= length
      return v[0...length] + "..."
    end
  end
end
