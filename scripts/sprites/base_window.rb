class BaseWindow
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
    @windowskin = Windowskin.get(windowskin || 1)
    @color = color
    @shadow_color = shadow_color
    @viewport = viewport
    @window = SplitSprite.new(@viewport)
    self.width = width
    self.height = height
    @window.set("gfx/windowskins/" + @windowskin.filename, @windowskin.center)
    @running = true
  end

  def width=(value)
    validate value => Integer
    @window.width = value
    @width = value
  end

  def height=(value)
    validate value => Integer
    @window.height = value
    @height = value
  end

  def windowskin=(value)
    validate value => [Integer, Windowskin]
    @windowskin = Windowskin.get(value)
    @window.set("gfx/windowskins/" + @windowskin.filename, @windowskin.center)
  end

  def running?
    return @running
  end

  def viewport
    return @window.viewport
  end

  def viewport=(value)
    @window.viewport = value
  end

  def x
    return @window.x
  end

  def x=(value)
    @window.x = value
  end

  def y
    return @window.y
  end

  def y=(value)
    @window.y = value
  end

  def visible
    return @window.visible
  end

  def visible=(value)
    @window.visible = value
  end

  def update
    return false unless @running
    return true
  end

  def dispose
    @window.dispose
  end
end
