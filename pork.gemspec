# -*- encoding: utf-8 -*-
# stub: pork 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "pork"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Lin Jen-Shin (godfat)"]
  s.date = "2014-11-16"
  s.description = "Pork -- Simple and clean and modular testing library.\n\nInspired by [Bacon][].\n\n[Bacon]: https://github.com/chneukirchen/bacon"
  s.email = ["godfat (XD) godfat.org"]
  s.files = [
  ".gitignore",
  ".gitmodules",
  ".travis.yml",
  "CHANGES.md",
  "Gemfile",
  "LICENSE",
  "README.md",
  "Rakefile",
  "lib/mutant/integration/pork.rb",
  "lib/pork.rb",
  "lib/pork/auto.rb",
  "lib/pork/context.rb",
  "lib/pork/error.rb",
  "lib/pork/executor.rb",
  "lib/pork/expect.rb",
  "lib/pork/ext.rb",
  "lib/pork/imp.rb",
  "lib/pork/inspect.rb",
  "lib/pork/stat.rb",
  "lib/pork/version.rb",
  "pork.gemspec",
  "task/README.md",
  "task/gemgem.rb",
  "test/test_bacon.rb",
  "test/test_nested.rb",
  "test/test_readme.rb"]
  s.homepage = "https://github.com/godfat/pork"
  s.licenses = ["Apache License 2.0"]
  s.rubygems_version = "2.4.4"
  s.summary = "Pork -- Simple and clean and modular testing library."
  s.test_files = [
  "test/test_bacon.rb",
  "test/test_nested.rb",
  "test/test_readme.rb"]
end
