# -*- encoding: utf-8 -*-
# stub: fcntl 1.0.0 ruby lib
# stub: ext/fcntl/extconf.rb

Gem::Specification.new do |s|
  s.name = "fcntl".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Yukihiro Matsumoto".freeze]
  s.bindir = "exe".freeze
  s.date = "2019-10-01"
  s.description = "Loads constants defined in the OS fcntl.h C header file".freeze
  s.email = ["matz@ruby-lang.org".freeze]
  s.extensions = ["ext/fcntl/extconf.rb".freeze]
  s.files = ["ext/fcntl/extconf.rb".freeze, "fcntl.so".freeze]
  s.homepage = "https://github.com/ruby/fcntl".freeze
  s.licenses = ["BSD-2-Clause".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Loads constants defined in the OS fcntl.h C header file".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.14"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 12"])
      s.add_development_dependency(%q<rake-compiler>.freeze, [">= 0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.14"])
      s.add_dependency(%q<rake>.freeze, ["~> 12"])
      s.add_dependency(%q<rake-compiler>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.14"])
    s.add_dependency(%q<rake>.freeze, ["~> 12"])
    s.add_dependency(%q<rake-compiler>.freeze, [">= 0"])
  end
end
