class Battle
  class MoveGROWL < BaseMove
    def after_hit_effect(user, target, damage, critical_hit)
      target.lower_stat(:attack, 1)
    end
  end
end

class Battle
  class MoveLEECHSEED < BaseMove
    def after_hit_effect(user, target, damage, critical_hit)
      user.sleep 2
    end
  end
end
