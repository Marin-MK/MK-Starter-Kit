# The trainer class that stores most Pokemon related data that's also specific to the player.
# For an instance of this class, use $trainer.
class Trainer
  # @return [Array<Pokemon>] the party of the player.
  attr_accessor :party
  # @return [PC] the storage PC of the player.
  attr_reader :pc
  # @return [Bag] the Bag of the player.
  attr_reader :bag
  # @return [Pokedex] the pokedex of the player.
  attr_reader :pokedex
  # @return [Integer] the Personal ID of the player.
  attr_reader :pid
  # @return [Integer] the Secret ID of the player.
  attr_reader :secret_id
  # @return [String] the name of the player.
  attr_accessor :name
  # @return [Integer] the gender of the player.
  attr_reader :gender
  # @return [Array] the badges of the player.
  attr_reader :badges
  # @return [Integer] the money of the player.
  attr_accessor :money
  # @return [Options] the options of the player.
  attr_reader :options

  # Creates a new Trainer object.
  def initialize
    @party = []
    @pc = PC.new
    @bag = Bag.new
    @pokedex = Pokedex.new
    @pid = rand(2 ** 16)
    @secret_id = rand(2 ** 16)
    @name = "RED"
    @gender = 0
    @badges = [false, false, false, false, false, false, false, false]
    @money = INITIAL_MONEY
    @options = Options.new
  end


  #============================================================================#
  # Party                                                                      #
  #============================================================================#

  # Adds the Pokemon to the party or PC if possible.
  # @param poke [Pokemon] the Pokemon to add.
  # @param obtain_type [Symbol] how this Pokemon was obtained.
  # @return [Boolean] whether the Pokemon could be added.
  def add_pokemon(poke, obtain_type = :MET)
    validate poke => Pokemon
    unless poke.ot_name && poke.ot_gender && poke.ot_pid
      poke.ot_name = @name
      poke.ot_gender = @gender
      poke.ot_pid = @pid
      poke.obtain_type = obtain_type
      poke.obtain_map = $game.map.id
      poke.obtain_time = Time.now
      poke.obtain_level = poke.level
      newot = true
    end
    if @party.size < 6
      @party << poke
      self.register_owned(poke)
      return true
    elsif !@pc.full && @pc.add_pokemon(poke)
      self.register_owned(poke)
    else
      if newot
        # Reset OT in case it wasn't actually added.
        poke.ot_name = nil
        poke.ot_gender = nil
        poke.ot_pid = nil
      end
      return false
    end
  end


  #============================================================================#
  # Bag                                                                        #
  #============================================================================#

  # Adds the item or items to the bag based on their associated pocket.
  # @param item [Symbol, Integer] the item to add to the bag.
  # @param count [Integer] the amount of items to add to the bag.
  # @return [Boolean] whether or not the item could be added to the bag.
  def add_item(item, count = 1)
    return @bag.add_item(item, count)
  end

  # @param item [Symbol, Integer] the item to look for.
  # @return [Boolean] whether or not the item exists in the bag.
  def has_item?(item)
    return @bag.has_item?(item)
  end

  # @param item [Symbol, Integer] the item to get the quantity of.
  # @return [Integer] how many of one item there is in the bag.
  def get_quantity(item)
    return @bag.get_quantity(item)
  end

  # Removes an item from the bag.
  # @param item [Symbol, Integer] the item to remove.
  # @param count [Integer] the number of items to remove.
  # @return [Boolean] whether or not any items were removed.
  def remove_item(item, count = 1)
    return @bag.remove_item(item, count)
  end


  #============================================================================#
  # Pokedex                                                                    #
  #============================================================================#

  # Registers the Pokemon or species as seen.
  # @param species [Symbol, Integer, Species, Pokemon] the species or Pokemon seen.
  # @param form [NilClass, Integer] the form of the species -- only works if a species is passed as first argument.
  def register_seen(species, form = nil)
    @pokedex.register_seen(species, form)
  end

  # Registers the Pokemon or species as owned.
  # @param species [Symbol, Integer, Species, Pokemon] the species or Pokemon owned.
  # @param form [NilClass, Integer] the form of the species -- only works if a species is passed as first argument.
  def register_owned(species, form = nil)
    @pokedex.register_owned(species, form = nil)
  end

  def has_pokedex?
    return @pokedex.enabled
  end

  def give_pokedex
    @pokedex.enabled = true
  end


  #============================================================================#
  # Money                                                                      #
  #============================================================================#

  def get_money_text
    str = @money.to_s
    return "$" + str if str.size <= 4 # $3000
    # If bigger, add commas
    str.reverse!
    newstr = ""
    for i in 0...str.size
      newstr << str[i]
      newstr << "," if (i + 1) % 3 == 0 && i < str.size - 1
    end
    return "$" + newstr.reverse
  end

  #============================================================================#
  # Badges                                                                     #
  #============================================================================#
  def has_badge?(n)
    return @badges[n - 1]
  end

  def give_badge(n)
    @badges[n - 1] = true
  end

  def badge_count(n)
    return @badges.count { |e| e }
  end
end
