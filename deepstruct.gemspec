# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "deepstruct/version"

Gem::Specification.new do |s|
  s.name        = "deepstruct"
  s.version     = Deepstruct::VERSION
  s.authors     = ["Simen Svale Skogsrud"]
  s.email       = ["simen@bengler.no"]
  s.homepage    = ""
  s.summary     = %q{A sibling of ostruct that handles deeply nested structures and basic data type detection}
  s.description = %q{A sibling of ostruct that handles deeply nested structures and basic data type detection}

  s.rubyforge_project = "deepstruct"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end
