class Battle
  class MoveGROWL < BaseMove
    def after_use_effect(user, target, damage, critical_hit)
      target.lower_stat(:attack, 1)
    end
  end
end
