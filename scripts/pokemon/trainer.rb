class Trainer
  attr_accessor :party
  attr_accessor :pc
  attr_accessor :pokedex

  def initialize
    @party = []
    @pc = PC.new
  end

  def add_pokemon(poke)
    if @party.size < 6
      @party << poke
      return true
    elsif !@pc.full?
      return @pc.add_pokemon(poke)
    else
      return false
    end
  end
end
