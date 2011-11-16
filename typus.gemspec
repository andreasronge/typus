# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "typus/version"

files = `git ls-files`.split("\n") + Dir["config/locales/*.yml"]
test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

Gem::Specification.new do |s|
  s.name = "typus"
  s.version = Typus::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Francesc Esplugas"]
  s.email = ["core@typuscms.com"]
  s.homepage = "http://core.typuscms.com/"
  s.summary = "Effortless backend interface for Ruby on Rails applications. (Admin scaffold generator)"
  s.description = "Ruby on Rails Admin Panel (Engine) to allow trusted users edit structured content."

  s.rubyforge_project = "typus"

  s.files         = files - test_files
  s.test_files    = []
  s.require_paths = ["lib"]

  s.add_dependency "bcrypt-ruby"
  s.add_dependency "fastercsv", "~> 1.5"
  s.add_dependency "rails", "~> 3.0.0"
  s.add_dependency "render_inheritable"
  s.add_dependency "will_paginate", "~> 3.0.0"
end
