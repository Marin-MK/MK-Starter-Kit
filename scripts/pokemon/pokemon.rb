class Pokemon
  def initialize(species, level)
    @species = species
    @level = level
  end

  # this saves us from typing pokemon.species.hidden_ability
  # see utils/module.rb for documentation on Module#delegate
  delegate Species::DELEGATED_PROPERTIES, to: :@species
end 