# Controller-only runtime check after installing the pinned test dependencies:
# bundle exec ruby test/activesupport_8_smoke.rb
require 'rubygems'
gem 'activesupport', '>= 8.0.5.2', '< 8.1'
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'cocoapods-core'

def check(condition, message)
  abort "FAIL: #{message}" unless condition
end

check(Gem::Requirement.new('>= 8.0.5.2', '< 8.1').satisfied_by?(Gem.loaded_specs.fetch('activesupport').version),
      'expected the fixed ActiveSupport 8.0 line')

# Metadata uses with_indifferent_access and HashWithIndifferentAccess internally.
metadata = Pod::Source::Metadata.new(:min => '1.0', :max => '2.0', :prefix_lengths => [1, 2])
check(metadata.minimum_cocoapods_version == Pod::Version.new('1.0'), 'symbol metadata keys')
check(metadata.compatible?('1.16.2'), 'metadata version compatibility')
check(metadata.to_hash[:min] == '1.0' && metadata.to_hash['min'] == '1.0', 'indifferent metadata serialization')

# Loading the specification DSL generates singular setters with AS inflections;
# description assignment calls strip_heredoc before serializing the specification.
spec = Pod::Specification.new do |s|
  s.name = 'CompatibilitySmoke'
  s.version = '1.0'
  s.author = 'Example'
  s.description = "    First line\n    Second line\n"
end
check(spec.authors == { 'Example' => nil }, 'singular author DSL setter')
check(spec.description == "First line\nSecond line", 'description heredoc normalization')
round_trip = Pod::Specification.from_json(spec.to_json)
check(round_trip.name == spec.name && round_trip.description == spec.description, 'specification JSON round trip')
puts "PASS: Core metadata and specification APIs with ActiveSupport #{ActiveSupport::VERSION::STRING}"
