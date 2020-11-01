class Windowskin < Serializable
  Cache = {}

  # @return [Symbol] the internal name of the windowskin.
  attr_accessor :intname
  # @return [Integer] the ID of the windowskin.
  attr_accessor :id
  # @return [Integer] the left-most X position where text can be drawn.
  attr_accessor :line_x_start
  # @return [Integer] the number of pixels in between horizontal list entries.
  attr_accessor :line_x_space
  # @return [Integer] the right-most X position where text can be drawn.
  attr_accessor :line_x_end
  # @return [Integer] the top-most Y position where text can be drawn.
  attr_accessor :line_y_start
  # @return [Integer] the number of pixels in between vertical list entries.
  attr_accessor :line_y_space
  # @return [String] the filename associated with this windowskin.
  attr_accessor :filename
  # @Return [Rect] the rectangle that is seen as the center of the windowskin.
  attr_accessor :center

  # Creates a new Windowskin object.
  def initialize(&block)
    validate block => Proc
    @id = 0
    instance_eval(&block)
    validate_windowskin
    Cache[@id] = self
  end

  # Ensures this windowskin contains valid data.
  def validate_windowskin
    validate \
        @intname => Symbol,
        @id => Integer,
        @line_x_start => Integer,
        @line_x_end => Integer,
        @line_y_start => Integer,
        @line_y_space => Integer,
        @filename => String,
        @center => Rect
    raise "Cannot have an ID lower than 0 for new Windowskin object" if @id < 0
  end

  # @param windowskin [Symbol, Integer] the windowskin to look up.
  # @return [Windowskin]
  def self.get(windowskin)
    validate windowskin => [Symbol, Integer, Windowskin]
    return windowskin if windowskin.is_a?(Windowskin)
    unless Windowskin.exists?(windowskin)
      raise "No windowskin could be found for #{windowskin.inspect}"
    end
    return Windowskin.try_get(windowskin)
  end

  # @param windowskin [Symbol, Integer] the windowskin to look up.
  # @return [Windowskin, NilClass]
  def self.try_get(windowskin)
    validate windowskin => [Symbol, Integer, Windowskin]
    return windowskin if windowskin.is_a?(Windowskin)
    return Cache[windowskin] if windowskin.is_a?(Integer)
    return Cache.values.find do |e|
      if windowskin == :choice && e.intname == :choice
        next e.id == $trainer.options.frame + 2
      else
        next e.intname == windowskin
      end
    end
  end

  # @param windowskin [Symbol, Integer] the windowskin to look up.
  # @return [Boolean] whether or not the windowskin exists.
  def self.exists?(windowskin)
    validate windowskin => [Symbol, Integer, Windowskin]
    return true if windowskin.is_a?(Windowskin)
    return true if !Cache[windowskin].nil?
    return Cache.values.any? { |e| e.intname == windowskin }
  end

  # Determines equality between two windowskins.
  # @param windowskin [Symbol, Integer, Windowskin] the windowskin to compare with.
  # @return [Boolean] whether the two windowskins are equal.
  def is?(windowskin)
    validate windowskin => [Symbol, Integer, Windowskin]
    return @intname == Windowskin.get(windowskin).intname
  end

  # @return [Integer] the maximum width for drawing text on this windowskin.
  def get_text_width(window_width)
    return window_width - @line_x_start - @line_x_end
  end

  # @return [Integer] the source width of the windowskin graphic.
  def source_width
    return 0 if @filename.size == 0
    source_bitmap = Bitmap.new("gfx/windowskins/" + @filename)
    ret = source_bitmap.width
    source_bitmap.dispose
    return ret
  end

  # @return [Integer] the source height of the windowskin graphic.
  def source_height
    return 0 if @filename.size == 0
    source_bitmap = Bitmap.new("gfx/windowskins/" + @filename)
    ret = source_bitmap.height
    source_bitmap.dispose
    return ret
  end
end

Windowskin.new do
  @intname = :speech
  @id = 1
  @line_x_start = 32
  @line_x_end = 68
  @line_y_start = 24
  @line_y_space = 30
  @filename = "speech"
  @center = Rect.new(32, 32, 32, 32)
end

Windowskin.new do
  @intname = :helper
  @id = 2
  @line_x_start = 16
  @line_x_end = 30
  @line_y_start = 26
  @line_y_space = 28
  @filename = "helper"
  @center = Rect.new(10, 10, 28, 28)
end

# choice windowskin for choices
Windowskin.new do
  @intname = :choice
  @id = 3
  @line_x_start = 32
  @line_x_end = 16
  @line_y_start = 26
  @line_y_space = 32
  @filename = "frame_1"
  @center = Rect.new(14, 14, 20, 20)
end

Windowskin.new do
  @intname = :choice
  @id = 4
  @line_x_start = 32
  @line_x_end = 16
  @line_y_start = 26
  @line_y_space = 32
  @filename = "frame_2"
  @center = Rect.new(14, 14, 20, 20)
end

Windowskin.new do
  @intname = :choice
  @id = 5
  @line_x_start = 32
  @line_x_end = 16
  @line_y_start = 26
  @line_y_space = 32
  @filename = "frame_3"
  @center = Rect.new(14, 14, 20, 20)
end

Windowskin.new do
  @intname = :choice
  @id = 6
  @line_x_start = 32
  @line_x_end = 16
  @line_y_start = 26
  @line_y_space = 32
  @filename = "frame_4"
  @center = Rect.new(14, 14, 20, 20)
end

Windowskin.new do
  @intname = :choice
  @id = 7
  @line_x_start = 32
  @line_x_end = 16
  @line_y_start = 26
  @line_y_space = 32
  @filename = "frame_5"
  @center = Rect.new(14, 14, 20, 20)
end

Windowskin.new do
  @intname = :choice
  @id = 8
  @line_x_start = 32
  @line_x_end = 16
  @line_y_start = 26
  @line_y_space = 32
  @filename = "frame_6"
  @center = Rect.new(14, 14, 16, 16)
end

Windowskin.new do
  @intname = :choice
  @id = 9
  @line_x_start = 32
  @line_x_end = 16
  @line_y_start = 26
  @line_y_space = 32
  @filename = "frame_7"
  @center = Rect.new(14, 14, 16, 16)
end

Windowskin.new do
  @intname = :choice
  @id = 10
  @line_x_start = 32
  @line_x_end = 16
  @line_y_start = 26
  @line_y_space = 32
  @filename = "frame_8"
  @center = Rect.new(12, 12, 16, 16)
end

Windowskin.new do
  @intname = :choice
  @id = 11
  @line_x_start = 32
  @line_x_end = 16
  @line_y_start = 26
  @line_y_space = 32
  @filename = "frame_9"
  @center = Rect.new(12, 12, 24, 24)
end

Windowskin.new do
  @intname = :choice
  @id = 12
  @line_x_start = 32
  @line_x_end = 16
  @line_y_start = 26
  @line_y_space = 32
  @filename = "frame_10"
  @center = Rect.new(14, 14, 16, 16)
end

Windowskin.new do
  @intname = :battle
  @id = 13
  @line_x_start = 20
  @line_x_end = 20
  @line_y_start = 26
  @line_y_space = 32
  @filename = "battle"
  @center = Rect.new(16, 14, 16, 20)
end

Windowskin.new do
  @intname = :battle_choice
  @id = 14
  @line_x_start = 32
  @line_x_end = 16
  @line_y_start = 26
  @line_y_space = 32
  @filename = "battle_choice"
  @center = Rect.new(14, 14, 16, 16)
end
