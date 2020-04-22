class Battle
  class BattlerSprite < CellSprite
    def initialize(pokemon, front, viewport = nil)
      super(viewport)
      pokemon = pokemon.pokemon if pokemon.is_a?(Battler)
      @pokemon = pokemon
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
  end
end
