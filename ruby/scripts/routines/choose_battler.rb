class PartyUI
  def self.start_choose_battler(party, &update)
    instance = self.new
    instance.start(party, &update)
    instance.hide_black { instance.update_sprites }
    return instance
  end

  def choose_battler
    test_disposed
    @choose_battler = true
    @return_value = nil
    until @stop || @disposed
      Graphics.update
      Input.update
      update_sprites
      update
      @stop = true if !@return_value.nil?
    end
    @stop = false
    return @return_value
  end

  def end_choose_battler
    @choose_battler = false
    self.dispose
  end

  alias choosebattler_get_selection_choices get_selection_choices
  def get_selection_choices
    return ["SHIFT", "SUMMARY", "CANCEL"] if @choose_battler
    return choosebattler_get_selection_choices
  end

  alias choosebattler_stop stop
  def stop
    if @choose_battler
      @stop = true
    else
      choosebattler_stop
    end
  end
end
