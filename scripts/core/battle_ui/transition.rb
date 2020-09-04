class Battle
  class Transition
    def initialize
      @viewport = Viewport.new(0, 0, System.width, System.height)
      @viewport.z = 999998
      @sprites = {}
      bmp = System.screenshot
      @sprites["overlay"] = Sprite.new(@viewport)
      @sprites["overlay"].bitmap = Bitmap.new(System.width, System.height)
      @sprites["overlay"].bitmap.fill_rect(0, 0, System.width, System.height, Color.new(72, 72, 72, 192))
      @sprites["overlay"].opacity = 0
      @sprites["overlay"].z = 1
      @sprites["one"] = Sprite.new(@viewport)
      @sprites["one"].bitmap = Bitmap.new(System.width, System.height)
      @sprites["two"] = Sprite.new(@viewport)
      @sprites["two"].bitmap = Bitmap.new(System.width, System.height)
      for y in 0...bmp.height
        if y % 2 == 0
          @sprites["one"].bitmap.blt(0, y, bmp, Rect.new(0, y, bmp.width, 1))
        else
          @sprites["two"].bitmap.blt(0, y, bmp, Rect.new(0, y, bmp.width, 1))
        end
      end
      bmp.dispose
    end

    def wait(seconds)
      for i in 1..framecount(seconds)
        update
      end
    end

    def flicker_overlay_in
      frames = framecount(0.1)
      for i in 1..frames
        update
        @sprites["overlay"].opacity += 192.0 / frames
      end
    end

    def flicker_overlay_out
      frames = framecount(0.1)
      for i in 1..frames
        update
        @sprites["overlay"].opacity -= 192.0 / frames
      end
    end

    def move_screen(pixels, speed)
      frames = framecount(speed)
      for i in 1..frames
        update
        @sprites["one"].x += pixels / frames.to_f
        @sprites["two"].x -= pixels / frames.to_f
      end
    end

    def main
      flicker_overlay_in
      flicker_overlay_out
      wait(0.08)
      flicker_overlay_in
      flicker_overlay_out
      wait(0.08)
      @sprites["overlay"].bitmap.fill_rect(0, 0, System.width, System.height, Color.new(0, 0, 0))
      @sprites["overlay"].opacity = 255
      @sprites["one"].z = 2
      @sprites["two"].z = 2
      move_screen(120, 0.15)
      move_screen(120, 0.08)
      move_screen(120, 0.05)
      move_screen(120, 0.03)
      dispose
    end

    def update
      System.update
    end

    def dispose
      @sprites.each_value(&:dispose)
      @viewport.dispose
    end
  end
end
