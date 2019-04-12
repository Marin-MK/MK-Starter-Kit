class PokemonBattlerSprite < Sprite
  def initialize(pokemon, viewport = nil)
    validate pokemon => Pokemon
    super(viewport)
    path = "gfx/pokemon/front/" + pokemon.species.intname.to_s.downcase
    if pokemon.male? && File.file?(path + "_m.png")
      path += "_m"
    elsif pokemon.female? && File.file?(path + "_f.png")
      path += "_f"
    elsif pokemon.genderless? && File.file?(path + "_g.png")
      path += "_g"
    end
    if File.file?(path + ".png")
      self.set_bitmap(path)
    else
      raise "No front battler sprite could be found for #{pokemon.species.intname.inspect}."
    end
  end
end
