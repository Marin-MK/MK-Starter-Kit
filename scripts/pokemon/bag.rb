class Trainer
  class Bag
    # @return [Array<Symbol>] the bag pockets to define.
    POCKETS = [:items, :key_items, :pokeballs]
    # @return [Hash] the maximum number of unique items per pocket.
    # If a pocket is not entered it is unlimited.
    MAX_POCKET_SIZE = {
      items: 42
    }
    # @return [Integer] maximum number of items you can have of one particular item.
    MAX_ITEM_SIZE = 999

    # @return [Array<Array<Hash>>] the bag pockets.
    attr_reader :pockets

    # Creates a new Bag object.
    def initialize
      @pockets = {}
      POCKETS.each { |e| @pockets[e] = [] }
    end

    # Adds the item or items to the bag based on their associated pocket.
    # @param item [Symbol, Integer] the item to add to the bag.
    # @param count [Integer] the amount of items to add to the bag.
    # @return [Boolean] whether or not the item could be added to the bag.
    def add_item(item, count = 1)
      validate item => [Symbol, Integer]
      item = Item.get(item)
      pocket = item.pocket
      unless @pockets[pocket]
        warn "Pocket #{pocket.inspect(16)} couldn't be found for item #{item.intname.inspect(16)}"
        pocket = POCKETS[0]
      end
      existing_item = @pockets[pocket].find { |e| e[:item] == item.intname }
      if existing_item
        if existing_item[:count] < MAX_ITEM_SIZE
          existing_item[:count] += count
          existing_item[:count] = [existing_item[:count], 999].min
        else
          return false
        end
      elsif !pocket_full?(pocket)
        @pockets[pocket] << {item: item.intname, count: count}
      else
        return false
      end
      return true
    end

    # @param pocket [Symbol] the pocket to determine if it's full.
    # @return [Boolean] whether or not the pocket is full.
    def pocket_full?(pocket)
      unless @pockets[pocket]
        warn "Pocket #{pocket.inspect(16)} couldn't be found"
        pocket = POCKETS[0]
      end
      return false unless MAX_POCKET_SIZE[pocket]
      return false if @pockets[pocket].size < MAX_POCKET_SIZE[pocket]
      return true
    end
  end
end
