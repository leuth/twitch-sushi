# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twitch_sushi/version'

Gem::Specification.new do |spec|
  spec.name          = 'twitch-sushi'
  spec.version       = TwitchSushi::VERSION
  spec.authors       = ['Wroc']
  spec.email         = ['sushi@example.com']

  spec.summary       = 'The Ruby library for Twitch API'
  spec.description   = 'Interfacing with Twitch API'
  spec.homepage      = ''
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = ""
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  # spec.files         = `git ls-files -z`.split("\x0").reject do |f|
  #   f.match(%r{^(test|spec|features)/})
  # end
  spec.files = Dir['{lib}/**/*.rb', 'bin/*', '*.md', 'LICENSE', '.yardopts']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4.2'
  spec.add_runtime_dependency 'addressable', '~> 2.5'
  spec.add_runtime_dependency 'httparty', '~> 0.15'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'yard', '~> 0.9'
end
