class << Input
  # Returns 1, 2, 3, 4, 6, 7, 8 or 9 depending on the directional buttons.
  # Allows diagonal.
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

  # Returns 2, 4, 6, or 8 depending on the directional buttons.
  # Prefers up/down over left/right.
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

  # Whether the confirm button is triggered.
  def confirm?
    return Input.trigger?(Input::A)
  end

  # Whether the cancel button is triggered.
  def cancel?
    return Input.trigger?(Input::B)
  end

  # Whether the down button is triggered.
  def down?
    return Input.trigger?(Input::DOWN)
  end

  # Whether the left button is triggered.
  def left?
    return Input.trigger?(Input::LEFT)
  end

  # Whether the right button is triggered.
  def right?
    return Input.trigger?(Input::RIGHT)
  end

  # Whether the up button is triggered.
  def up?
    return Input.trigger?(Input::UP)
  end
end