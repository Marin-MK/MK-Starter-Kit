class BaseUI
  include Disposable

  def initialize(folder = "", x = 0, y = 0, width = Graphics.width, height = Graphics.height)
    @path = "gfx/ui/" + folder
    @path << "/" if folder.size > 0
    @viewport = Viewport.new(x, y, width, height)
    @viewport.z = 99999
    @sprites = {}
    @stop = false
    @disposed = false
    @ret = 0
  end

  def main
    test_disposed
    until @stop || @disposed
      Graphics.update
      Input.update
      update_sprites
      update
    end
  end

  def update
    test_disposed
  end

  def update_sprites
    test_disposed
    @sprites.each_value(&:update)
  end

  def return_value
    return @ret
  end

  def stop
    test_disposed
    return if stopped?
    @stop = true
  end

  def stopped?
    return @stop
  end

  def dispose
    test_disposed
    stop
    @sprites.each_value(&:dispose)
    @viewport.dispose
    super
  end
end
