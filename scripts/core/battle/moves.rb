class Battle
  class MoveGROWL < BaseMove
    def after_use_effect(user, target, damage, critical_hit)
      #target.lower_stat(:attack, 1)
      if chance(0.4)
        target.burn
      end
      if chance(0.4)
        target.lower_stat :attack, 1
      end
    end
  end
end
