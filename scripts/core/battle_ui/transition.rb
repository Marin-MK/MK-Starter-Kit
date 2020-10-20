class Battle
  class Transition
    # Create a new battle transition
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

    # Wait for a certain number of seconds
    # @param seconds [Float] the number of seconds to wait.
    def wait(seconds)
      for i in 1..framecount(seconds)
        update
      end
    end

    # Flickers the overlay in.
    def flicker_overlay_in
      frames = framecount(0.1)
      for i in 1..frames
        update
        @sprites["overlay"].opacity += 192.0 / frames
      end
    end

    # Flickers the overlay out.
    def flicker_overlay_out
      frames = framecount(0.1)
      for i in 1..frames
        update
        @sprites["overlay"].opacity -= 192.0 / frames
      end
    end

    # Moves the screen by a certain amount at a certain speed.
    # @param pixels [Integer] the number of pixels to move the screen by.
    # @param speed [Float] the number of seconds over which to apply the movement.
    def move_screen(pixels, speed)
      frames = framecount(speed)
      for i in 1..frames
        update
        @sprites["one"].x += pixels / frames.to_f
        @sprites["two"].x -= pixels / frames.to_f
      end
    end

    # Performs the transition.
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
    end

    # Updates the animation's visuals.
    def update
      System.update
    end

    # Disposes the transition and it visuals.
    def dispose
      @sprites.each_value(&:dispose)
      @viewport.dispose
    end
  end
end
