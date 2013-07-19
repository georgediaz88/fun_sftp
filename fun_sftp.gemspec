# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fun_sftp/version"

Gem::Specification.new do |s|
  s.name        = "fun_sftp"
  s.version     = FunSftp::VERSION
  s.authors     = ["George Diaz"]
  s.email       = ["georgediaz88@yahoo.com"]
  s.homepage    = "https://rubygems.org/gems/fun_sftp"
  s.summary     = %q{FunSFTP for secure file transfers}
  s.description = %q{Wrapper for Ruby's Net::SFTP library which makes SFTP easy! See Documentation at https://github.com/georgediaz88/fun_sftp}

  s.rubyforge_project = "fun_sftp"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency 'net-sftp'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry'
end
