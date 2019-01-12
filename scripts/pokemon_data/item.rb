class Item
  Cache = {}

  # @return [Symbol] the internal name of the item.
  attr_reader :intname
  # @return [Integer] the ID of the item.
  attr_reader :id
  # @return [String] the name of the item.
  attr_reader :name
  # @return [Symbol] the pocket this item belongs in.
  attr_reader :pocket
  # @return [Integer] how much this item costs in a PokeMart.
  attr_reader :price
  # @return [String] the description for this item.
  attr_reader :description
  # @return [Integer] how much damage this item does when used with Fling.
  attr_reader :fling_power

  # Creates a new Item object.
  def initialize(&block)
    validate block => Proc
    @id = 0
    @name = ""
    @price = 0
    @description = ""
    @fling_power = 0
    instance_eval(&block)
    validate_item
    Cache[@intname] = self
    self.class.const_set(@intname, self)
  end

  # Ensures this item contains valid data.
  def validate_item
    validate @intname => Symbol,
        @id => Integer,
        @name => String,
        @pocket => Symbol,
        @price => Integer,
        @description => String,
        @fling_power => Integer
    raise "Cannot have an ID of 0 or lower for new Item object" if @id < 1
  end

  # @param item [Symbol, Integer] the item to look up.
  # @return [Item]
  def self.get(item)
    validate item => [Symbol, Integer]
    unless Item.exists?(item)
      raise "No item could be found for #{item.inspect(50)}"
    end
    return Item.try_get(item)
  end

  # @param item [Symbol, Integer] the item to look up.
  # @return [Item, NilClass]
  def self.try_get(item)
    validate item => [Symbol, Integer]
    return Cache[item] if item.is_a?(Symbol)
    return Cache.values.find { |i| i.id == item }
  end

  # @param item [Symbol, Integer] the item to look up.
  # @return [Boolean] whether or not the item exists.
  def self.exists?(item)
    validate item => [Symbol, Integer]
    return Cache.has_key?(item) if item.is_a?(Symbol)
    return Cache.values.any? { |i| i.id == item }
  end

  # @return [Item] a randomly chosen item's internal name.
  def self.random
    return Cache.keys.sample
  end
end

# This would be loaded from a data file
Item.new do
  @intname = :REPEL
  @id = 1
  @name = "Repel"
  @pocket = :items
  @price = 350
  @description = "Prevents weak wild Pokémon from appearing for 100 steps."
  @fling_power = 30
end

Item.new do
  @intname = :SUPERREPEL
  @id = 2
  @name = "Super Repel"
  @pocket = :items
  @price = 500
  @description = "Prevents weak wild Pokémon from appearing for 200 steps."
  @fling_power = 30
end

Item.new do
  @intname = :MAXREPEL
  @id = 3
  @name = "Max Repel"
  @pocket = :items
  @price = 700
  @description = "Prevents weak wild Pokémon from appearing for 250 steps."
  @fling_power = 30
end
