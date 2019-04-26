class UsableMove
  attr_reader :intname
  attr_reader :id
  attr_accessor :pp

  # Creates a new UsableMove object.
  def initialize(move)
    move = Move.get(move)
    @intname = move.intname
    @id = move.id
    @pp = move.totalpp
  end

  def move
    return Move.get(@intname)
  end

  def name
    return self.move.name
  end

  def type
    return self.move.type
  end

  def power
    return self.move.power
  end

  def totalpp
    return self.move.totalpp
  end

  def accuracy
    return self.move.accuracy
  end

  def category
    return self.move.category
  end

  def target_mode
    return self.move.target_mode
  end

  def description
    return self.move.description
  end

  def heal_pp
    self.pp = self.move.totalpp
  end
end
