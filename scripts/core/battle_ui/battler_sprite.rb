class Battle
  class BattlerSprite < CellSprite
    attr_reader :pokemon

    # Creates a new battler sprite.
    # @param pokemon [Battler, Pokemon] the Pokémon to use in the file path.
    # @param front [Boolean] whether to use the front or back sprite.
    # @param viewport [Viewport] the viewport of the sprite.
    def initialize(pokemon, front, viewport = nil)
      validate \
          pokemon => [Battler, Pokemon],
          front => Boolean,
          viewport => [NilClass, Viewport]
      super(viewport)
      pokemon = pokemon.pokemon if pokemon.is_a?(Battler)
      @pokemon = pokemon
      @front = front
      # Looks through all variants of the file to find the best match.
      suffix = pokemon.shiny? ? "_shiny" : ""
      path = "gfx/pokemon/#{front ? "front" + suffix : "back" + suffix}/" + pokemon.species.intname.to_s.downcase
      if pokemon.male? && File.file?(path + "_m.png")
        path += "_m"
      elsif pokemon.female? && File.file?(path + "_f.png")
        path += "_f"
      elsif pokemon.genderless? && File.file?(path + "_o.png")
        path += "_o"
      elsif pokemon.shiny?
        # Try normal if previously tried shiny
        path = "gfx/pokemon/#{front ? "front" : "back"}/" + pokemon.species.intname.to_s.downcase
        if pokemon.male? && File.file?(path + "_m.png")
          path += "_m"
        elsif pokemon.female? && File.file?(path + "_f.png")
          path += "_f"
        elsif pokemon.genderless? && File.file?(path + "_o.png")
          path += "_o"
        end
      end
      if File.file?(path + ".png")
        # load the detected file.
        self.bitmap = Bitmap.new(path)
        self.set_cell(self.bitmap.width, self.bitmap.height)
      else
        raise "No battler sprite could be found for '#{pokemon.species.intname.inspect}' with the following parameters:\n" +
            "Gender: #{pokemon.male? ? "Male (_m)" : pokemon.female? ? "Female (_f)" : "Genderless (_o)"}\n" +
            "Shiny: #{pokemon.shiny?.to_s.capitalize}"
      end
    end

    # Start an async animation to make the sprite grow from the bottom center.
    # @param duration [Float] the number of seconds for the animation to take.
    def appear_from_ball(duration)
      validate duration => Float
      x = self.x - self.ox
      y = self.y - self.oy
      self.ox = self.src_rect.width / 2
      self.oy = self.src_rect.height
      self.x = x + self.ox
      self.y = y + self.oy
      self.zoom_x = 0
      self.zoom_y = 0
      @appear_frames = framecount(duration)
      @appear_counter = 0
    end

    # Start an async animation to make the sprite shrink to the bottom center.
    # @param duration [Float] the number of seconds for the animation to take.
    def disappear_into_ball(duration)
      validate duration => Float
      x = self.x - self.ox
      y = self.y - self.oy
      self.ox = self.src_rect.width / 2
      self.oy = self.src_rect.height
      self.x = x + self.ox
      self.y = y + self.oy
      self.zoom_x = 1
      self.zoom_y = 1
      @disappear_frames = framecount(duration)
      @disappear_counter = 0
    end

    # Update the sprite and performs the appear and disappear animations.
    def update
      super
      if @appear_frames && @appear_counter
        @appear_counter += 1.0
        self.zoom_x = @appear_counter / @appear_frames
        self.zoom_y = @appear_counter / @appear_frames
        if @appear_counter == @appear_frames
          @appear_counter = nil
          @appear_frames = nil
        end
      end
      if @disappear_frames && @disappear_counter
        @disappear_counter += 1.0
        self.zoom_x = 1 - @disappear_counter / @disappear_frames
        self.zoom_y = 1 - @disappear_counter / @disappear_frames
        if @disappear_counter == @disappear_frames
          @disappear_counter = nil
          @disappear_frames = nil
        end
      end
    end
  end
end
