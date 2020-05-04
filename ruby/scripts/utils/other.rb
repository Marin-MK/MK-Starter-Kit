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

# Translates symbols to actual special characters in the font
def symbol(n)
  characters = {
    pkmn: "²³",
    lv: "¤",
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

def warn(msg)
  log(:WARNING, msg)
end

def log(category, msg, no_duplicates = false)
  if $LOG && $LOG[category]
    line = "#{category}: #{msg}\n"
    unless line == $LOG[:_last] && no_duplicates
      $LOG[:_last] = line
      print line
    end
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

  def deep_clone
    return Marshal.load(Marshal.dump(self))
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

  def dump_data
    array = []
    self.each do |value|
      value = value.dump_data if value.respond_to?(:dump_data)
      array << value
    end
    return array
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

  def dump_data
    hash = {}
    self.each do |key, value|
      key = key.dump_data if key.respond_to?(:dump_data)
      value = value.dump_data if value.respond_to?(:dump_data)
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

class Serializable
  # Converts an object to JSON
  def dump_data(options = {})
    vars = {"^c" => self.class}
    instance_variables.each do |e|
      key = e.to_s
      vars[key] = instance_variable_get(e)
      vars[key] = vars[key].dump_data if vars[key].respond_to?(:dump_data)
      vars[key] = vars[key].replace_symbols if vars[key].is_a?(Array, Hash)
      vars[key] = ":" + vars[key].to_s if vars[key].is_a?(Symbol)
    end
    return vars
  end
end

class Struct
  def dump_data(options = {})
    vars = {"^c" => self.class}
    self.keys.each do |e|
      key = "@" + e.to_s
      vars[key] = get(e)
      vars[key] = vars[key].dump_data if vars[key].respond_to?(:dump_data)
      vars[key] = vars[key].replace_symbols if vars[key].is_a?(Array, Hash)
      vars[key] = ":" + vars[key].to_s if vars[key].is_a?(Symbol)
    end
    return vars
  end
end

class Rect
  # @return [Boolean] whether this Rect overlaps the given rect or vice-versa.
  def overlaps?(rect)
    return (rect.x >= self.x && rect.x < self.x + self.width  || rect.x + rect.width  > self.x && rect.x + rect.width  < self.x + self.width ) &&
           (rect.y >= self.y && rect.y < self.y + self.height || rect.y + rect.height > self.y && rect.y + rect.height < self.y + self.height) ||
           (self.x >= rect.x && self.x < rect.x + rect.width  || self.x + self.width  > rect.x && self.x + self.width  < rect.x + rect.width ) &&
           (self.y >= rect.y && self.y < rect.y + rect.height || self.y + self.height > rect.y && self.y + self.height < rect.y + rect.height)
  end

  # @return [Array<width, height>] the difference of the two rectangles; the space between them.
  def distance(rect)
    return nil if self.overlaps?(rect)
    diffx = 0
    if self.x > rect.x + rect.width
      diffx = self.x - (rect.x + rect.width)
    elsif rect.x > self.x + self.width
      diffx = rect.x - (self.x + self.width)
    end
    diffy = 0
    if self.y > rect.y + rect.height
      diffy = self.y - (rect.y + rect.height)
    elsif rect.y > self.y + self.height
      diffy = rect.y - (self.y + self.height)
    end
    return [diffx, diffy]
  end
end

def weighted_rand(weights)
  num = rand(weights.sum)
  for i in 0...weights.size
    if num < weights[i]
      return i
    else
      num -= weights[i]
    end
  end
end

def weighted_factored_rand(factor, weights)
  avg = weights.sum / weights.size.to_f
  newweights = weights.map do |e|
    diff = e - avg
    next [0, ((e - diff * factor) * 100).round].max
  end
  return weighted_rand(newweights)
end
