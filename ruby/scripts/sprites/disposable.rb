module Disposable
  def dispose
    test_disposed
    @disposed = true
  end

  def disposed?
    return @disposed == true
  end

  def test_disposed
    if disposed?
      raise "This object has been disposed, making this method inaccessible.\n\n" + caller.join("\n")
    end
  end
end
