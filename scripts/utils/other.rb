# Inherit on a class to allow Class.Constant besides Class::Constant.
class Enum
  class << self
    def method_missing(name)
      return const_get(name)
    end
  end
end