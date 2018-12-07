class << Input
  # @return [Fixnum] one of the 8 directions based on the arrow keys.
  def dir8
    l = Input.press?(Input::LEFT)
    r = Input.press?(Input::RIGHT)
    d = Input.press?(Input::DOWN)
    u = Input.press?(Input::UP)
    l = r = false if r && l
    d = u = false if u && d
    return 1 if l && d
    return 3 if d && r
    return 9 if r && u
    return 7 if u && l
    return 4 if l
    return 2 if d
    return 6 if r
    return 8 if u
    return 0
  end

  # @return [Fixnum] one of the 4 directions based on the arrow keys.
  def dir4
    l = Input.press?(Input::LEFT)
    r = Input.press?(Input::RIGHT)
    d = Input.press?(Input::DOWN)
    u = Input.press?(Input::UP)
    l = r = false if r && l
    d = u = false if u && d
    return 2 if d
    return 8 if u
    return 6 if r
    return 4 if l
    return 0
  end

  # @return [Boolean] whether the confirm button is triggered.
  def confirm?
    return Input.trigger?(Input::A)
  end

  # @return [Boolean] whether the cancel button is triggered.
  def cancel?
    return Input.trigger?(Input::B)
  end

  # @return [Boolean] whether the down button is triggered.
  def down?
    return Input.trigger?(Input::DOWN)
  end

  # @return [Boolean] whether the left button is triggered.
  def left?
    return Input.trigger?(Input::LEFT)
  end

  # @return [Boolean] whether the right button is triggered.
  def right?
    return Input.trigger?(Input::RIGHT)
  end

  # @return [Boolean] whether the up button is triggered.
  def up?
    return Input.trigger?(Input::UP)
  end
end