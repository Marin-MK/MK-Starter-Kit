class Array
  def replace_symbols
    array = []
    self.each do |value|
      value = value.replace_symbols if value.is_a?(Array, Hash)
      value = ":" + value.to_s if value.is_a?(Symbol)
      array << value
    end
    return array
  end

  def normalize_symbols
    array = []
    self.each do |value|
      value = value.normalize_symbols if value.is_a?(Array, Hash)
    end
  end
end

class Hash
  # Converts all :symbol keys to ":symbol" keys for JSON compatibility
  def replace_symbols
    hash = {}
    self.each do |key, value|
      if key.is_a?(Symbol)
        key = ":" + key.to_s
      end
      value = value.replace_symbols if value.is_a?(Array, Hash)
      value = ":" + value.to_s if value.is_a?(Symbol)
      hash[key] = value
    end
    return hash
  end

  def rename(oldkey, newkey)
    self[newkey] = self[oldkey]
    self.delete(oldkey)
    return self
  end
end

# Translates symbols to actual special characters in the font
def symbol(n)
  characters = {
    PKMN: "²³",
    Lv: "¤",
    female: "¬",
    male: "£"
  }
  return characters[n] if characters[n]
  raise "Invalid symbol #{n.inspect}"
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

#temp
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
  RED = Color.new(255, 0, 0)
  GREEN = Color.new(0, 255, 0)
  BLUE = Color.new(0, 0, 255)
  WHITE = Color.new(255, 255, 255)
  BLACK = Color.new(0, 0, 0)

  GREYBASE = Color.new(96, 96, 96)
  GREYSHADOW = Color.new(208, 208, 200)

  LIGHTBASE = Color.new(248, 248, 248)
  LIGHTSHADOW = Color.new(96, 96, 96)
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

class Serializable
  # Converts an object to JSON
  def to_json(options = {})
    vars = {"^c" => self.class}
    instance_variables.each do |e|
      vars[e] = instance_variable_get(e)
      vars[e] = vars[e].replace_symbols if vars[e].is_a?(Array, Hash)
      vars[e] = ":" + vars[e].to_s if vars[e].is_a?(Symbol)
    end
    return vars.to_json
  end
end

class Struct
  def to_json(options = {})
    vars = {"^c" => self.class}
    self.keys.each do |e|
      key = "@" + e.to_s
      vars[key] = get(e)
      vars[key] = vars[key].replace_symbols if vars[key].is_a?(Array, Hash)
      vars[key] = ":" + vars[key].to_s if vars[key].is_a?(Symbol)
    end
    return vars.to_json
  end
end
