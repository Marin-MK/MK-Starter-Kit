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

module MemInfo
  # This uses backticks to figure out the pagesize, but only once
  # when loading this module.
  # You might want to move this into some kind of initializer
  # that is loaded when your app starts and not when autoload
  # loads this module.
  KERNEL_PAGE_SIZE = `getconf PAGESIZE`.chomp.to_i rescue 4096
  STATM_PATH       = "/proc/#{Process.pid}/statm"
  STATM_FOUND      = File.exist?(STATM_PATH)

  def self.rss
    STATM_FOUND ? (File.read(STATM_PATH).split(' ')[1].to_i * KERNEL_PAGE_SIZE) / 1024 : 0
  end
end

# @return [Fixnum] the amount of memory the game is currently using.
def get_memory
  ret = `pmap #{Process.pid} | tail -1`.reverse
  return ret[2...ret.index(' ')].reverse.to_i
end

# Performs a memory and speed test.
# @param abort_after [Boolean] whether or not to shut down after performing the test.
def perform_test(abort_after = true)
  smem = get_memory
  st = Time.now
  yield
  et = (Time.now - st).round(4)
  emem = get_memory
  msgbox "Memory Before: #{smem}\nMemory After: #{emem}\nMemory Difference: #{emem > smem ? "+" : emem < smem ? "-" : ""}#{emem - smem}\n----------------------\n" +
      "Time: #{et} seconds"
  abort if abort_after
end
