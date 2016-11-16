
begin
  require "#{__dir__}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init --recursive'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

Gemgem.init(__dir__) do |s|
  require 'pork/version'
  s.name    = 'pork'
  s.version = Pork::VERSION
  s.files.delete('screenshot.png')

  %w[method_source ruby-progressbar].
    each(&s.method(:add_development_dependency))
end
