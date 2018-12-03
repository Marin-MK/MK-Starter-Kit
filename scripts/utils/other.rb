# Inherit on a class to allow Class.Constant besides Class::Constant.
class Enum
  class << self
    def method_missing(name)
      return const_get(name)
    end
  end
end

# Ensure #msgbox always pops up a box, no matter the RGSS version
unless defined?(msgbox) == "method"
	def msgbox(*args)
		p *args
	end
end