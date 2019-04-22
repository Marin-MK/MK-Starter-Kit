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

def warn(*args)
  p *args
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

[Object, String, Symbol, Integer, Fixnum, Bignum].each do |c|
  c.class_eval do
    next if defined?(:oldinspect)
    alias oldinspect inspect
    def inspect(length = 0)
      v = oldinspect
      return v if length < 1
      return v if v.size <= length
      return v[0...length] + "..."
    end
  end
end

class Object
  alias old_is_a? is_a?
  def is_a?(*args)
    return args.any? { |e| old_is_a?(e) }
  end
end

class Struct
  class << self
    alias oldnew new
    def new(*args)
      r = oldnew(*args)
      r.send(:define_method, :keys) { next args }
      r.send(:define_method, :get) { |key| method(key).call }
      r.send(:define_method, :set) { |key, value| method(key.to_s + '=').call(value) }
      return r
    end
  end
end

module Boolean
end

class TrueClass
  include Boolean
end

class FalseClass
  include Boolean
end

class Color
  RED = Color.new(224, 8, 8)
  BLUE = Color.new(48, 80, 200)
  GREY = Color.new(96, 96, 96)
  SHADOW = Color.new(208, 208, 200)
end


FrameCache = {}

def framecount(n)
  return FrameCache[n] if FrameCache[n]
  FrameCache[n] = (n * Graphics.frame_rate).ceil
  return FrameCache[n]
end


class Array
  def swap(idx1, idx2)
    copy = self[idx2].clone
    self[idx2] = self[idx1]
    self[idx1] = copy
    return self
  end

  def swap!(idx1, idx2)
    self.replace(self.swap(idx1, idx2))
  end
end
