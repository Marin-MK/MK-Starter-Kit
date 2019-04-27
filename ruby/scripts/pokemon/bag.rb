class Trainer
  class Bag
    # @return [Array<Symbol>] the bag pockets to define.
    POCKETS = [:items, :key_items, :pokeballs]
    POCKET_NAMES = {
      items: "ITEMS",
      key_items: "KEY ITEMS",
      pokeballs: "POKé BALLS"
    }
    # @return [Hash] the maximum number of unique items per pocket.
    # If a pocket is not entered it is unlimited.
    MAX_POCKET_SIZE = {
      items: 42
    }
    # @return [Integer] maximum number of items you can have of one individual item.
    MAX_ITEM_SIZE = 999

    # @return [Array<Array<Hash>>] the bag pockets.
    attr_reader :pockets
    # @return [Array<Hash>>] last indexes used per pocket.
    attr_reader :indexes
    # @return [Symbol] the last opened bag pocket.
    attr_accessor :last_pocket

    # Creates a new Bag object.
    def initialize
      @pockets = {}
      @indexes = {}
      @last_pocket = POCKETS[0]
      POCKETS.each do |e|
        @pockets[e] = []
        @indexes[e] = {top_idx: 0, list_idx: 0}
      end
    end

    # Adds the item or items to the bag based on their associated pocket.
    # @param item [Symbol, Integer] the item to add to the bag.
    # @param count [Integer] the amount of items to add to the bag.
    # @return [Boolean] whether or not the item could be added to the bag.
    def add_item(item, count = 1)
      validate item => [Symbol, Integer, Item]
      item = Item.get(item)
      pocket = item.pocket
      existing_item = @pockets[pocket].find { |e| e[:item] == item.intname }
      if existing_item
        if existing_item[:count] < MAX_ITEM_SIZE
          existing_item[:count] += count
          existing_item[:count] = [existing_item[:count], MAX_ITEM_SIZE].min
        else
          return false
        end
      elsif !pocket_full?(pocket)
        @pockets[pocket] << {item: item.intname, count: [count, MAX_ITEM_SIZE].min}
      else
        return false
      end
      return true
    end

    # @param item [Symbol, Integer] the item to look for.
    # @return [Boolean] whether or not the item exists in the bag.
    def has_item?(item)
      validate item => [Symbol, Integer, Item]
      item = Item.get(item)
      pocket = item.pocket
      name = item.intname
      return @pockets[pocket].any? { |e| e[:item] == name && e[:count] > 0 }
    end

    # @param item [Symbol, Integer] the item to get the quantity of.
    # @return [Integer] how many of one item there is in the bag.
    def get_quantity(item)
      validate item => [Symbol, Integer, Item]
      return 0 unless self.has_item?(item)
      item = Item.get(item)
      pocket = item.pocket
      name = item.intname
      return @pockets[pocket].find { |e| e[:item] == name }[:count]
    end

    # Removes an item from the bag.
    # @param item [Symbol, Integer] the item to remove.
    # @param count [Integer] the number of items to remove.
    # @return [Boolean] whether or not any items were removed.
    def remove_item(item, count = 1)
      validate item => [Symbol, Integer, Item], count => Integer
      return false unless self.has_item?(item)
      item = Item.get(item)
      pocket = item.pocket
      name = item.intname
      for i in 0...@pockets[pocket].size
        slot = @pockets[pocket][i]
        if slot[:item] == name
          if slot[:count] > count
            slot[:count] -= count
          else
            @pockets[pocket].delete_at(i)
          end
          return true
        end
      end
      return false
    end

    # @param pocket [Symbol] the pocket to determine if it's full.
    # @return [Boolean] whether or not the pocket is full.
    def pocket_full?(pocket)
      unless @pockets[pocket]
        raise "Pocket #{pocket.inspect} couldn't be found"
      end
      return false unless MAX_POCKET_SIZE[pocket]
      return false if @pockets[pocket].size < MAX_POCKET_SIZE[pocket]
      return true
    end
  end
end
