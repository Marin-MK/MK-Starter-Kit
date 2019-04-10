class Windowskin
  Cache = []

  # @return [Integer] the ID of the windowskin.
  attr_accessor :id
  # @return [Integer] the left-most X position where text can be drawn.
  attr_accessor :line_x_start
  # @return [Integer] the right-most X position where text can be drawn.
  attr_accessor :line_x_end
  # @return [Integer] the top-most Y position where text can be drawn.
  attr_accessor :line_y_start
  # @return [Integer] the number of pixels in between lines.
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
    validate @id => Integer,
        @line_x_start => Integer,
        @line_x_end => Integer,
        @line_y_start => Integer,
        @line_y_space => Integer,
        @filename => String,
        @center => Rect
    raise "Cannot have an ID lower than 0 for new Windowskin object" if @id < 0
  end

  # @param windowskin [Integer] the windowskin to look up.
  # @return [Windowskin]
  def self.get(windowskin)
    validate windowskin => [Integer, Windowskin]
    return windowskin if windowskin.is_a?(Windowskin)
    unless Windowskin.exists?(windowskin)
      raise "No windowskin could be found for #{windowskin.inspect(50)}"
    end
    return Windowskin.try_get(windowskin)
  end

  # @param windowskin [Integer] the windowskin to look up.
  # @return [Windowskin, NilClass]
  def self.try_get(windowskin)
    validate windowskin => [Integer, Windowskin]
    return windowskin if windowskin.is_a?(Windowskin)
    return Cache[windowskin]
  end

  # @param windowskin [Symbol, Integer] the windowskin to look up.
  # @return [Boolean] whether or not the windowskin exists.
  def self.exists?(windowskin)
    validate windowskin => [Integer, Windowskin]
    return true if windowskin.is_a?(Windowskin)
    return !Cache[windowskin].nil?
  end

  # @return [Integer] the maximum width for drawing text on this windowskin.
  def get_text_width(window_width)
    return window_width - @line_x_start - self.source_width + @line_x_end - 8
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
  @id = 0
  @line_x_start = 0
  @line_x_end = -4
  @line_y_start = 2
  @line_y_space = 30
  @filename = ""
  @center = Rect.new(0, 0, 0, 0)
end

Windowskin.new do
  @id = 1
  @line_x_start = 22
  @line_x_end = 48
  @line_y_start = 18
  @line_y_space = 30
  @filename = "main"
  @center = Rect.new(22, 28, 40, 28)
end

Windowskin.new do
  @id = 2
  @line_x_start = 30
  @line_x_end = 74
  @line_y_start = 20
  @line_y_space = 30
  @filename = "choice"
  @center = Rect.new(12, 12, 68, 68)
end

Windowskin.new do
  @id = 3
  @line_x_start = 12
  @line_x_end = 44
  @line_y_start = 22
  @line_y_space = 30
  @filename = "helper_window"
  @center = Rect.new(16, 16, 24, 24)
end
