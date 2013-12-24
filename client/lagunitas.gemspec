# -*- encoding: utf-8 -*-
require File.expand_path('../lib/lagunitas/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'lagunitas'
  s.version = Lagunitas::VERSION.dup
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.authors = ['Brian Moseley']
  s.description = 'Lagunitas user service client library'
  s.email = ['bcm@copious.com']
  s.homepage = 'http://github.com/utahstreetlabs/lagunitas'
  s.rdoc_options = ['--charset=UTF-8']
  s.summary = "A client library for the Lagunitas user service"
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files -- lib/*`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_development_dependency('rake')
  s.add_development_dependency('mocha')
  s.add_development_dependency('rspec')
  s.add_development_dependency('gemfury')
  if ENV['LAGUNITAS_DEBUG']
    s.add_development_dependency('ruby-debug19')
    s.add_development_dependency('ruby-debug-base19')
  end
  s.add_runtime_dependency('ladon', '>= 4.1.2')
end
