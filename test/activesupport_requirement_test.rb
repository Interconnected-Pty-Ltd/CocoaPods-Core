# Run with ruby; only RubyGems and the standard library are needed.
require 'rubygems'

spec = Gem::Specification.load(File.expand_path('../cocoapods-core.gemspec', __dir__))
abort 'FAIL: could not load gemspec' unless spec
dependency = spec.runtime_dependencies.find { |item| item.name == 'activesupport' }
abort 'FAIL: missing activesupport dependency' unless dependency

failures = []
%w[5.0 5.2.8.1 6.1.7.10 7.0.8.7 7.1.5.2 7.2.2.2 8.0.5.2].each do |version|
  failures << "FAIL: expected #{version} to be accepted" unless dependency.requirement.satisfied_by?(Gem::Version.new(version))
end
%w[4.2.11.3 8.1 8.1.0 8.1.1 9.0 9.0.0].each do |version|
  failures << "FAIL: expected #{version} to be rejected" if dependency.requirement.satisfied_by?(Gem::Version.new(version))
end
failures << 'FAIL: Core version changed' unless spec.version == Gem::Version.new('1.16.2')
abort failures.join("\n") unless failures.empty?
puts 'PASS: ActiveSupport requirement accepts prior lines and 8.0.5.2, rejects 4.x/8.1/9; Core remains 1.16.2'
