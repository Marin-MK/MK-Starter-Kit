class Battle
  class BattlerSprite < CellSprite
    attr_reader :pokemon

    def initialize(pokemon, front, viewport = nil)
      super(viewport)
      pokemon = pokemon.pokemon if pokemon.is_a?(Battler)
      @pokemon = pokemon
      @front = front
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
        self.bitmap = Bitmap.new(path)
        self.set_cell(self.bitmap.width, self.bitmap.height)
      else
        raise "No battler sprite could be found for '#{pokemon.species.intname.inspect}' with the following parameters:\n" +
            "Gender: #{pokemon.male? ? "Male (_m)" : pokemon.female? ? "Female (_f)" : "Genderless (_o)"}\n" +
            "Shiny: #{pokemon.shiny?.to_s.capitalize}"
      end
    end

    def appear_from_ball(duration)
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

    def disappear_into_ball(duration)
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
