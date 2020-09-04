class PokemonIcon < Sprite
  def initialize(pokemon, viewport = nil)
    super(viewport)
    self.set_pokemon(pokemon)
  end

  def set_pokemon(pokemon)
    @pokemon = pokemon
    self.set_bitmap("gfx/pokemon/icons/#{@pokemon.species.intname.to_s.downcase}")
    self.src_rect.width = self.bitmap.width / 2
    self.ox = self.src_rect.width / 2
  end

  def set_frame(n)
    self.src_rect.x = n * self.src_rect.width
    @i = 0
  end

  def update
    @i ||= 0
    @i += 1
    time = 0.15
    time = 0.25 if @pokemon.hp / @pokemon.totalhp.to_f <= 0.5
    time = 0.35 if @pokemon.hp / @pokemon.totalhp.to_f <= 0.25
    if @i % framecount(time) == 0
      self.src_rect.x += self.src_rect.width
      self.src_rect.x = 0 if self.src_rect.x >= self.bitmap.width
    end
  end
end
