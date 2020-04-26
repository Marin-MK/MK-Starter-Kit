class Battle
  class BaseMove
    def initialize(battle, move)
      @battle = battle
      @move = move
    end

    def physical?
      return @move.physical?
    end

    def special?
      return @move.special?
    end

    def status?
      return @move.status?
    end

    def message(msg)
      @battle.message(msg)
    end

    def get_target(user)
      if @move.target == :single_opponent
        # Battler directly opposite this battler.
        return @battle.sides[1 - user.side].battlers[user.index]
      elsif @move.target == :self
        return user
      elsif @move.target == :adjacent_opponents
        # TODO: Support for triple battles (only target adjacent 2)
        return @battle.sides[1 - user.side].battlers
      elsif @move.target == :all_opponents
        return @battle.sides[1 - user.side].battlers
      elsif @move.target == :ally
        return @battle.sides[user.side].battlers[1 - user.index]
      elsif @move.target == :all_others
        return [@battle.sides[user.side].battlers[1 - user.index]].concat(@battle.sides[1 - user.side].battlers)
      elsif @move.target == :everyone
        return @battle.sides[user.side].battlers.concat(@battle.sides[1 - user.side].battlers)
      end
    end

    def critical_hit?
      return false
    end

    def self.get_type_effectiveness_modifier(move_type, target_types)
      mod = 1.0
      target_types.each do |target_type|
        mod *= 2.0 if Type.get(move_type).strong_against?(target_type)
        mod /= 2.0 if Type.get(target_type).resistant_to?(move_type)
      end
      return mod
    end

    def get_damage_multiplier(user, target, multiple_targets, critical_hit)
      mod = 1.0
      # TODO: Weather boosting
      mod *= 0.75 if multiple_targets
      mod *= 1.5 if critical_hit
      mod *= rand(85..100) / 100.0
      mod *= 1.5 if user.has_type?(@move.type)
      mod *= BaseMove.get_type_effectiveness_modifier(@move.type, target.types)
      mod *= 0.5 if user.burned? && physical?
      return mod
    end

    def get_user_attack(user, target, multiple_targets, critical_hit)
      if physical?
        attack = user.attack
        attack = user.pokemon.attack if critical_hit && user.attack < user.pokemon.attack # Ignore negative stat stages
      else
        attack = user.spatk
        attack = user.pokemon.spatk if critical_hit && user.spatk < user.pokemon.spatk # Ignore negative stat stages
      end
      return attack
    end

    def get_target_defense(user, target, multiple_targets, critical_hit)
      if physical?
        defense = target.defense
        defense = target.pokemon.defense if critical_hit && target.defense > target.pokemon.defense # Ignore negative stat stages
      else
        defense = target.spdef
        defense = target.pokemon.spdef if critical_hit && target.spdef > target.pokemon.spdef # Ignore negative stat stages
      end
      return defense
    end

    def calculate_damage(user, target, multiple_targets, critical_hit)
      attack = get_user_attack(user, target, multiple_targets, critical_hit)
      defense = get_target_defense(user, target, multiple_targets, critical_hit)
      dmg = (2 * user.level / 5 + 2) * @move.power * attack / defense / 50 + 2
      dmg *= get_damage_multiplier(user, target, multiple_targets, critical_hit)
      dmg = 1 if dmg < 1
      return dmg.floor
    end

    def execute(user)
      targets = get_target(user)
      targets = [targets] if targets.is_a?(Battler)
      crit = critical_hit?
      for target in targets
        damage = status? ? nil : calculate_damage(user, target, targets.size > 1, crit)
        
      end
    end
  end
end
