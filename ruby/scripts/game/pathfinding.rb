class Game
  class Pathfinder
    class Node
      attr_accessor :position
      attr_accessor :parent_node

      # Value indicative of how efficient the route via this node is
      attr_accessor :f
      # Distance between starting node and this node
      attr_accessor :g
      # Estimated distance from this node to the destination
      attr_accessor :h

      def initialize(*args)
        if args.size == 3
          validate \
              args[0] => Integer,
              args[1] => Integer,
              args[2] => Node
          @position = Position.new(args[0], args[1])
          @parent_node = args[2]
        elsif args.size == 2
          if args[0].is_a?(Integer) && args[1].is_a?(Integer)
            @position = Position.new(*args)
          elsif args[0].is_a?(Position) && args[1].is_a?(Node)
            @position = args[0]
            @parent_node = args[1]
          else
            raise "Invalid arguments for node creation"
          end
        else
          validate args[0] => Position
          @position = args[0]
        end
        @f = 0
        @g = 0
        @h = 0
      end
    end

    class Position
      attr_accessor :x
      attr_accessor :y

      def initialize(x, y)
        @x = x
        @y = y
      end

      def ==(obj)
        if obj.is_a?(Position)
          return @x == obj.x && @y == obj.y
        else
          return false
        end
      end
    end

    attr_accessor :open_list
    attr_accessor :closed_list
    attr_accessor :begin_node
    attr_accessor :dest_node
    attr_accessor :result

    def initialize(event, startx, starty, destx, desty)
      @event = event
      @begin_node = Node.new(startx, starty)
      @dest_node = Node.new(destx, desty)
      @open_list = [@begin_node]
      @closed_list = []
      @result = nil
    end

    def can_run?
      return !@open_list.empty? && @result.nil?
    end

    def run
      current_node = @open_list[0]
      current_index = 0
      # Continue with the node with the lowest cost value
      @open_list.each_with_index do |node, index|
        if node.f < current_node.f
          current_node = node
          current_index = index
        end
      end
      @open_list.delete(current_node)
      @closed_list << current_node

      # Reached destination node
      if current_node.position == @dest_node.position
        path = []
        while current_node
          path << current_node.position
          current_node = current_node.parent_node
        end
        @result = path.reverse
        return
      end

      children = []
      offsets = [Position.new(0, 1), Position.new(-1, 0), Position.new(1, 0), Position.new(0, -1)]
      dirs = [:down, :left, :right, :up]
      for i in 0...offsets.size
        position_offset = offsets[i]
        dir = dirs[i]
        node_position = Position.new(current_node.position.x + position_offset.x, current_node.position.y + position_offset.y)
        next if !$game.maps[@event.map_id].passable?(node_position.x, node_position.y, dir, @event)
        new_node = Node.new(node_position, current_node)
        children << new_node
      end

      children.each do |child_node|
        next if @closed_list.include?(child_node)
        child_node.g = current_node.g + 1
        child_node.h = (child_node.position.x - @dest_node.position.x) ** 2 + (child_node.position.y - @dest_node.position.y) ** 2
        child_node.f = child_node.g + child_node.h
        append = true
        @open_list.each do |open_node|
          if child_node.position == open_node.position && child_node.g > open_node.g
            append = false
          end
        end
        @open_list << child_node if append
      end
    end
  end
end
