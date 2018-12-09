class Pokemon
  # Creates a new Pokemon object.
  # @param species [Fixnum, Symbol, String] the species of the Pokemon.
  # @param level [Fixnum] the level of the Pokemon.
  def initialize(species, level)
    @species = species
    @level = level
  end

  # Allows you to type pokemon.weight instead of pokemon.species.weight
  # but only for the list of delegated properties that can be seen in species.rb
  delegate Species::DELEGATED_PROPERTIES, to: :@species
end
