# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "marionette/version"

Gem::Specification.new do |s|
  s.name        = "marionette"
  s.version     = HeadStartApp::Marionette::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dan Lee"]
  s.email       = ["dan@headstartapp.com"]
  s.homepage    = "http://headstartapp.com"
  s.summary     = %q{0MQ connection between puppet and master.}
  s.description = %q{Marionette connects a headstartapp server instance (puppet node) to its master and executes puppet runs on demand. Marionette uses fast and lightweight 0MQ <http://zeromq.org> messaging system.}

  s.rubyforge_project = "marionette"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.executables << 'marionette-master'
  s.executables << 'marionette-puppet'
  s.add_dependency('zmq')
  s.add_dependency('ffi')
  s.add_dependency('ffi-rzmq')
  s.add_dependency('daemons')
  s.require_paths = ["lib"]
  s.bindir        = "bin"
  s.require_paths = ["lib"]
end