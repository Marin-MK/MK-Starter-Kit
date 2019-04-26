class Trainer
  # The trainer's pokedex. Tracks species and forms seen/owned.
  class Pokedex
    # @return [Hash<Symbol, Array>] the list of species and forms seen.
    attr_reader :seen
    # @return [Hash<Symbol, Array>] the list of species and forms owned.
    attr_reader :owned
    # @return [Boolean] whether or not Pokemon are being registered as seen or owned.
    attr_accessor :enabled

    # Creates a new Pokedex object.
    def initialize
      @seen = {}
      @owned = {}
      @enabled = false
    end

    def obtained?
      return @enabled
    end

    def seen_count
      return @seen.values.count { |e| e.is_a?(Array) && e.size > 0 }
    end

    def owned_count
      return @owned.values.count { |e| e.is_a?(Array) && e.size > 0 }
    end

    # Registers the Pokemon or species as seen.
    # @param species [Symbol, Integer, Species, Pokemon] the species or Pokemon seen.
    # @param form [NilClass, Integer] the form of the species -- only works if a species is passed as first argument.
    def register_seen(species, form = nil)
      validate species => [Symbol, Integer, Species, Pokemon], form => [Integer, NilClass]
      if species.is_a?(Pokemon)
        pokemon = species
        species = pokemon.species.intname
        form = pokemon.form
      elsif species.is_a?(Symbol, Integer, Species)
        species = Species.get(species).intname
        form = form || 0
      end
      @seen[species] ||= []
      @seen[species] << form unless @seen[species].include?(form)
    end

    # Registers the Pokemon or species as owned.
    # @param species [Symbol, Integer, Species, Pokemon] the species or Pokemon owned.
    # @param form [NilClass, Integer] the form of the species -- only works if a species is passed as first argument.
    def register_owned(species, form = nil)
      validate species => [Symbol, Integer, Species, Pokemon], form => [Integer, NilClass]
      if species.is_a?(Pokemon)
        pokemon = species
        species = pokemon.species.intname
        form = pokemon.form
      elsif species.is_a?(Symbol, Integer, Species)
        species = Species.get(species).intname
        form = form || 0
      end
      @owned[species] ||= []
      @owned[species] << form unless @owned[species].include?(form)
    end
  end
end
