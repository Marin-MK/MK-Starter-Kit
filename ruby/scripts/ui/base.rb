class BaseUI
  include Disposable

  def self.start(*args)
    instance = self.new
    instance.start(*args)
    instance.main
    instance.dispose
    return instance.return_value
  end

  attr_accessor :path
  attr_accessor :viewport
  attr_accessor :sprites
  attr_accessor :ret

  def start(update: nil, path: nil, fade: true, fade_time: 0.3, wait_time: 0.3)
    log(:UI, "Starting scene " + self.class.to_s)
    validate \
        path => [NilClass, String],
        fade => Boolean,
        fade_time => Float
    if path
      @path = "gfx/ui/" + path
      @path << "/" if path.size > 0
    end
    @fade = fade
    @fade_time = fade_time
    @wait_time = wait_time
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @stop = false
    @disposed = false
    @ret = true
    @update = update
    show_black(:opening) { @update.call if @update } if @fade
  end

  def main
    test_disposed
    if @fade
      wait(@wait_time)
      hide_black { update_sprites }
    end
    until @stop || @disposed
      Graphics.update
      update_sprites
      update
    end
  end

  def update
    test_disposed
  end

  def update_sprites(no_update: [])
    test_disposed
    @sprites.each do |key, sprite|
      if sprite.disposed?
        @sprites.delete(key)
      else
        sprite.update unless no_update.include?(key)
      end
    end
  end

  def return_value
    return @ret
  end

  def stop
    test_disposed
    return if stopped?
    show_black { update_sprites; @update.call if @update } if @fade
    @stop = true
  end

  def stopped?
    return @stop
  end

  def dispose
    log(:UI, "Stopping scene " + self.class.to_s)
    test_disposed
    stop
    @sprites.each_value(&:dispose)
    @viewport.dispose
    super
    if @fade
      wait(@wait_time)
      hide_black(:closing)
    end
  end

  def show_black(mode = nil)
    if Graphics.brightness == 255
      frames = framecount(@fade_time)
      decrease = 255.0 / frames
      for i in 1..frames
        Graphics.brightness = 255 - (decrease * i).round
        yield if block_given?
        Graphics.update
      end
    else
      Graphics.brightness = 0
    end
  end

  def hide_black(mode = nil)
    if Graphics.brightness == 0
      frames = framecount(@fade_time)
      increase = 255.0 / frames
      for i in 1..frames
        Graphics.brightness = (increase * i).round
        yield if block_given?
        Graphics.update
      end
    else
      Graphics.brightness = 255
    end
  end

  def wait(n)
    framecount(n).times do
      update_sprites unless disposed?
      yield if block_given?
      Graphics.update
    end
  end
end
