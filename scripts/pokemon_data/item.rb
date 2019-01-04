class Item
  Cache = {}

  attr_reader :intname
  attr_reader :id
  attr_reader :name
  attr_reader :pocket
  attr_reader :price
  attr_reader :description
  attr_reader :fling_power

  def initialize(&block)
    validate block => Proc
    @id = 0
    instance_eval(&block)
    validate_item
    Cache[@intname] = self
    self.class.const_set(@intname, self)
  end

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

  def self.get(item)
    validate item => [Symbol, Integer]
    unless Item.exists?(item)
      raise "No item could be found for #{item.inspect(50)}"
    end
    return Item.try_get(item)
  end

  def self.try_get(item)
    validate item => [Symbol, Integer]
    return Cache[item] if item.is_a?(Symbol)
    return Cache.values.find { |i| i.id == item }
  end

  def self.exists?(item)
    validate item => [Symbol, Integer]
    return Cache.has_key?(item) if item.is_a?(Symbol)
    return Cache.values.any? { |i| i.id == item }
  end

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
