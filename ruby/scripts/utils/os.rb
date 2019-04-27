module OS
  def self.windows?
    return (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def self.mac?
   return (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def self.unix?
    return !self.windows?
  end

  def self.linux?
    return self.unix? && !self.mac?
  end

  def self.jruby?
    return RUBY_ENGINE == 'jruby'
  end
end
