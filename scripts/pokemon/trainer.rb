# The trainer class that stores most Pokemon related data that's also specific to the player.
# For an instance of this class, use $trainer.
class Trainer
  # @return [Array<Pokemon>] the party of the player.
  attr_accessor :party
  # @return [PC] the storage PC of the player.
  attr_accessor :pc
  # @return [Bag] the Bag of the player.
  attr_accessor :bag
  # @return [Integer] the Personal ID of the player.
  attr_reader :pid
  # @return [Integer] the Secret ID of the player.
  attr_reader :secret_id

  # Creates a new Trainer object.
  def initialize
    @party = []
    @pc = PC.new
    @bag = Bag.new
    @pid = rand(2 ** 16)
    @secret_id = rand(2 ** 16)
  end

  # Adds the Pokemon to the party or PC if possible.
  # @param poke [Pokemon] the Pokemon to add.
  # @return [Boolean] whether the Pokemon could be added.
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
