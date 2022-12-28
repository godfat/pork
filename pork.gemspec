# -*- encoding: utf-8 -*-
# stub: pork 2.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "pork".freeze
  s.version = "2.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Lin Jen-Shin (godfat)".freeze]
  s.date = "2022-12-28"
  s.description = "Pork -- Simple and clean and modular testing library.\n\nInspired by [Bacon][].\n\n[Bacon]: https://github.com/chneukirchen/bacon".freeze
  s.email = ["godfat (XD) godfat.org".freeze]
  s.files = [
  ".gitignore".freeze,
  ".gitlab-ci.yml".freeze,
  ".gitmodules".freeze,
  "CHANGES.md".freeze,
  "Gemfile".freeze,
  "LICENSE".freeze,
  "README.md".freeze,
  "Rakefile".freeze,
  "TODO.md".freeze,
  "lib/pork.rb".freeze,
  "lib/pork/api.rb".freeze,
  "lib/pork/auto.rb".freeze,
  "lib/pork/context.rb".freeze,
  "lib/pork/env.rb".freeze,
  "lib/pork/error.rb".freeze,
  "lib/pork/executor.rb".freeze,
  "lib/pork/expect.rb".freeze,
  "lib/pork/extra/rainbows.rb".freeze,
  "lib/pork/extra/show_source.rb".freeze,
  "lib/pork/inspect.rb".freeze,
  "lib/pork/isolator.rb".freeze,
  "lib/pork/mode/parallel.rb".freeze,
  "lib/pork/mode/sequential.rb".freeze,
  "lib/pork/mode/shuffled.rb".freeze,
  "lib/pork/more.rb".freeze,
  "lib/pork/more/bottomup_backtrace.rb".freeze,
  "lib/pork/more/color.rb".freeze,
  "lib/pork/more/should.rb".freeze,
  "lib/pork/report.rb".freeze,
  "lib/pork/report/description.rb".freeze,
  "lib/pork/report/dot.rb".freeze,
  "lib/pork/report/progressbar.rb".freeze,
  "lib/pork/runner.rb".freeze,
  "lib/pork/stat.rb".freeze,
  "lib/pork/suite.rb".freeze,
  "lib/pork/test.rb".freeze,
  "lib/pork/version.rb".freeze,
  "pork.gemspec".freeze,
  "task/README.md".freeze,
  "task/gemgem.rb".freeze,
  "test/test_around.rb".freeze,
  "test/test_bacon.rb".freeze,
  "test/test_expect.rb".freeze,
  "test/test_inspect.rb".freeze,
  "test/test_isolator.rb".freeze,
  "test/test_meta.rb".freeze,
  "test/test_nested.rb".freeze,
  "test/test_pork_test.rb".freeze,
  "test/test_readme.rb".freeze,
  "test/test_should.rb".freeze,
  "test/test_stat.rb".freeze,
  "test/test_suite.rb".freeze]
  s.homepage = "https://github.com/godfat/pork".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.rubygems_version = "3.4.1".freeze
  s.summary = "Pork -- Simple and clean and modular testing library.".freeze
  s.test_files = [
  "test/test_around.rb".freeze,
  "test/test_bacon.rb".freeze,
  "test/test_expect.rb".freeze,
  "test/test_inspect.rb".freeze,
  "test/test_isolator.rb".freeze,
  "test/test_meta.rb".freeze,
  "test/test_nested.rb".freeze,
  "test/test_pork_test.rb".freeze,
  "test/test_readme.rb".freeze,
  "test/test_should.rb".freeze,
  "test/test_stat.rb".freeze,
  "test/test_suite.rb".freeze]

  s.specification_version = 4

  s.add_development_dependency(%q<method_source>.freeze, [">= 0"])
  s.add_development_dependency(%q<ruby-progressbar>.freeze, [">= 0"])
end
