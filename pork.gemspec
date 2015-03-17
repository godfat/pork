# -*- encoding: utf-8 -*-
# stub: pork 1.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "pork"
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Lin Jen-Shin (godfat)"]
  s.date = "2015-03-17"
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
  "TODO.md",
  "lib/pork.rb",
  "lib/pork/auto.rb",
  "lib/pork/context.rb",
  "lib/pork/env.rb",
  "lib/pork/error.rb",
  "lib/pork/executor.rb",
  "lib/pork/expect.rb",
  "lib/pork/extra/rainbows.rb",
  "lib/pork/imp.rb",
  "lib/pork/inspect.rb",
  "lib/pork/mode/parallel.rb",
  "lib/pork/mode/sequential.rb",
  "lib/pork/mode/shuffled.rb",
  "lib/pork/more.rb",
  "lib/pork/more/bottomup_backtrace.rb",
  "lib/pork/more/color.rb",
  "lib/pork/more/should.rb",
  "lib/pork/stat.rb",
  "lib/pork/test.rb",
  "lib/pork/version.rb",
  "pork.gemspec",
  "task/README.md",
  "task/gemgem.rb",
  "test/test_bacon.rb",
  "test/test_inspect.rb",
  "test/test_nested.rb",
  "test/test_readme.rb",
  "test/test_should.rb"]
  s.homepage = "https://github.com/godfat/pork"
  s.licenses = ["Apache License 2.0"]
  s.rubygems_version = "2.4.6"
  s.summary = "Pork -- Simple and clean and modular testing library."
  s.test_files = [
  "test/test_bacon.rb",
  "test/test_inspect.rb",
  "test/test_nested.rb",
  "test/test_readme.rb",
  "test/test_should.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<muack>, [">= 0"])
    else
      s.add_dependency(%q<muack>, [">= 0"])
    end
  else
    s.add_dependency(%q<muack>, [">= 0"])
  end
end
