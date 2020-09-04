class Battle
  class AI
    attr_accessor :self

    def initialize(battle, skill = 50)
      @battle = battle
      @skill = skill
      @projection = BattleProjection.new
    end

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

    def pick_move_and_target(user)
      scores = []
      for target in @projection.battlers
        for i in 0...4
          move = user.moves[i]
          if !move.nil?
            next if move.pp <= 0
            score = get_move_score(user, target, move)
            next if score.nil?
            scores << [score, i, target]
          end
        end
      end
      scores.sort! { |a, b| a[0] <=> b[0] }
      skill = @skill / -50.0 + 1
      idx = weighted_factored_rand(skill, scores.map { |e| e[0] })
      return [user.moves[scores[idx][1]], scores[idx][2]]
    end

    def get_move_score(user, target, move)
      if move.status?
        score = 30
      else
        score = move.power
      end
      return score
    end
  end
end
