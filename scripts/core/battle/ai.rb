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

    # Present an opposing battler to the AI to remember.
    # @param battler [Battler] the battler to show the AI.
    def show_battler(battler)
      if projection = @projection.party.find { |e| p.battler == battler }
        @projection.battlers << projection
      else
        projection = BattlerProjection.new(battler)
        @projection.battlers << projection
        @projection.party << projection
      end
    end

    def recall_battler(battler)
      @projection.battlers.delete(battler)
    end

    # Picks a move and target for a battler.
    # @param user [Battler] the battler that is to choose a move and target.
    def pick_move_and_target(user)
      # An array of scores in the format of [score_value, move_index, target]
      scores = []
      # Calculate a score for all targets
      for target in @projection.battlers
        # Calculate a score for all the user's moves
        for i in 0...4
          move = user.moves[i]
          if !move.nil?
            next if move.pp <= 0
            # Get the move score given a user and a target
            score = get_move_score(user, target, move)
            next if score.nil?
            scores << [score, i, target]
          end
        end
      end
      # Sort the scores based on score value
      scores.sort! { |a, b| a[0] <=> b[0] }
      # Map the numeric skill factor to a -1..1 range
      skill = @skill / -50.0 + 1
      # Get a random move based on weights and an average multiplication factor
      idx = weighted_factored_rand(skill, scores.map { |e| e[0] })
      # Return [MoveObject, target]
      return [user.moves[scores[idx][1]], scores[idx][2]]
    end

    # Calculates the score of a move based on the user and target.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the simulated target of the move.
    # @param move [MoveObject] the move to use.
    # @return [Integer] the numeric score of this combination of user, target and move.
    def get_move_score(user, target, move)
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
