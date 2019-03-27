class BaseWindow
  include Disposable

  attr_reader :width
  attr_reader :height
  attr_reader :windowskin
  attr_reader :viewport
  attr_accessor :color
  attr_accessor :shadow_color

  def initialize(width, height, windowskin, color = Color::BLUE, shadow_color = Color::SHADOW, viewport = nil)
    validate width => Integer,
        height => Integer,
        windowskin => [Integer, NilClass, Windowskin],
        color => Color,
        shadow_color => Color,
        viewport => [NilClass, Viewport]
    super()
    @windowskin = Windowskin.get(windowskin || 1)
    @color = color
    @shadow_color = shadow_color
    @viewport = viewport
    @window = SplitSprite.new(@viewport)
    self.width = width
    self.height = height
    @window.set("gfx/windowskins/" + @windowskin.filename, @windowskin.center) if @windowskin.filename.size > 0
    @running = true
  end

  def width=(value)
    test_disposed
    validate value => Integer
    @window.width = value
    @width = value
  end

  def height=(value)
    test_disposed
    validate value => Integer
    @window.height = value
    @height = value
  end

  def windowskin=(value)
    test_disposed
    validate value => [Integer, Windowskin]
    @windowskin = Windowskin.get(value)
    @window.set("gfx/windowskins/" + @windowskin.filename, @windowskin.center) if @windowskin.filename.size > 0
  end

  def running?
    return @running
  end

  def viewport
    return @window.viewport
  end

  def viewport=(value)
    test_disposed
    @window.viewport = value
  end

  def x
    return @window.x
  end

  def x=(value)
    test_disposed
    @window.x = value
  end

  def y
    return @window.y
  end

  def y=(value)
    test_disposed
    @window.y = value
  end

  def z
    return @window.z
  end

  def z=(value)
    test_disposed
    @window.z = value
  end

  def visible
    return @window.visible
  end

  def visible=(value)
    test_disposed
    @window.visible = value
  end

  def update
    test_disposed
    return false unless @running
    return true
  end

  def dispose
    super
    @window.dispose
  end
end
