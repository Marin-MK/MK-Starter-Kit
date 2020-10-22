class Battle
  class AI
    attr_accessor :self

    # Creates a new AI object to mirror a battle.
    # @param battle [Battle] the battle to mirror.
    # @param skill [Integer] the skill level of the AI.
    def initialize(battle, skill = 50)
      @battle = battle
      @skill = skill
      @projection = BattleProjection.new
    end

    # Mark a battler as active.
    # @param side [Integer] the side the battler belongs to.
    # @param battler [Battler] the battler to log.
    def register_battler(side, battler)
      show_battler(side, battler)
      projection = @projection.sides[side].party.find { |p| p.battler == battler }
      if !@projection.sides[side].battlers.include?(projection)
        @projection.sides[side].battlers << projection
      end
    end

    # Present a battler for the AI to remember.
    # @param side [Integer] the side the battler belongs to.
    # @param battler [Battler] the battler to log.
    def show_battler(side, battler)
      if !@projection.sides[side].party.any? { |p| p.battler == battler }
        projection = BattlerProjection.new(battler)
        @projection.sides[side].party << projection
      end
    end

    # Mark a battler as inactive.
    # @param side [Integer] the side the battler belongs to.
    # @param battler [Battler] the battler to log.
    def deregister_battler(side, battler)
      projection = @projection.sides[side].battlers.find { |p| p.battler == battler }
      @projection.sides[side].battlers.delete(projection)
    end

    # Picks a move and target for a battler.
    # @param user [Battler] the battler that is to choose a move and target.
    def pick_move_and_target(side, user)
      validate \
          side => Integer,
          user => Battler
      # An array of scores in the format of [score_value, move_index, target]
      scores = []
      # Gets the projection of the opposing side
      opposing_side = @projection.sides[1 - side]
      # Calculate a score for all targets
      for target in opposing_side.battlers
        # Calculate a score for all the user's moves
        for i in 0...4
          move = user.moves[i]
          if !move.nil?
            next if move.pp <= 0
            # Get the move score given a user and a target
            score = get_move_score(user, target, move)
            next if score.nil?
            scores << [score, i, 1 - side, opposing_side.battlers.index(target)]
          end
        end
      end
      # Sort the scores based on score value
      scores.sort! { |a, b| a[0] <=> b[0] }
      # Map the numeric skill factor to a -1..1 range
      skill = @skill / -50.0 + 1
      # Get a random move based on weights and an average multiplication factor
      idx = weighted_factored_rand(skill, scores.map { |e| e[0] })
      # Return [UsableMove, target]
      return [user.moves[scores[idx][1]], scores[idx][2], scores[idx][3]]
    end

    # Calculates the score of a move based on the user and target.
    # @param user [Battler] the user of the move.
    # @param target [BattlerProjection] the projected target of the move.
    # @param move [UsableMove] the move to use.
    # @return [Integer] the numeric score of this combination of user, target and move.
    def get_move_score(user, target, move)
      # The target variable is a projection of a battler. We know its species and HP,
      # but its item, ability, moves and other properties are not known unless they are
      # explicitly shown or mentioned. Knowing these properties can change what our AI
      # chooses; if we know the item of our target projection, and it's an Air Balloon,
      # we won't choose a Ground move, for instance.
      validate \
          user => Battler,
          target => BattlerProjection,
          move => UsableMove
      if move.status?
        # Start status moves off with a score of 30.
        # Since this makes status moves unlikely to be chosen when the other moves
        # have a high base power, all status moves should ideally be addressed in this
        # method, and used in the optimal scenario for each individual move.
        score = 30
      else
        # Set the move score to the base power of the move
        score = move.power
      end
      return score
    end
  end
end
