class BaseWindow
  include Disposable

  attr_reader :width
  attr_reader :height
  attr_reader :windowskin
  attr_reader :viewport
  attr_accessor :running
  attr_accessor :drawing

  def initialize(width, height, windowskin, viewport = nil)
    validate \
        width => Integer,
        height => Integer,
        windowskin => [Symbol, Integer, NilClass, Windowskin],
        viewport => [NilClass, Viewport]
    super()
    @windowskin = Windowskin.get(windowskin || :speech)
    @viewport = viewport
    @window = SplitSprite.new(@viewport)
    @text_sprite = Sprite.new(@viewport)
    self.width = width
    self.height = height
    @window.set("gfx/windowskins/" + @windowskin.filename, @windowskin.center) if @windowskin.filename.size > 0
    @running = true
    @drawing = false
  end

  def width=(value)
    test_disposed
    validate value => Integer
    @window.width = value
    @window.refresh if @window.set?
    @width = value
  end

  def height=(value)
    test_disposed
    validate value => Integer
    @window.height = value
    @window.refresh if @window.set?
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

  def drawing?
    return @drawing
  end

  def viewport
    return @window.viewport
  end

  def viewport=(value)
    test_disposed
    @window.viewport = value
    @text_sprite.viewport = value
  end

  def x
    return @window.x
  end

  def x=(value)
    test_disposed
    @window.x = value
    @text_sprite.x = value
  end

  def y
    return @window.y
  end

  def y=(value)
    test_disposed
    @window.y = value
    @text_sprite.y = value
  end

  def z
    return @window.z
  end

  def z=(value)
    test_disposed
    @window.z = value
    @text_sprite.z = value
  end

  def visible
    return @window.visible
  end

  def visible=(value)
    test_disposed
    @window.visible = value
    @text_sprite.visible = value
  end

  def clear
    @text_sprite.bitmap.clear if @text_sprite.bitmap
  end

  def draw_text(*args)
    if @text_sprite.bitmap.nil?
      @text_sprite.bitmap = Bitmap.new(@window.width, @window.height)
    end
    @text_sprite.draw_text(*args)
  end

  def update
    test_disposed
    return false unless @running
    return true
  end

  def dispose
    super
    @window.dispose
    @text_sprite.dispose
  end
end
