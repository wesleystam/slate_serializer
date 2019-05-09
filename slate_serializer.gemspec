lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slate_serializer/version'

Gem::Specification.new do |spec|
  spec.name          = 'slate_serializer'
  spec.version       = SlateSerializer::VERSION
  spec.authors       = ['Wesley Stam']
  spec.email         = ['wesley@stam.me']
  spec.license       = "MIT"

  spec.summary       = 'Serializer for Slate documents written in Ruby'
  spec.homepage      = 'https://github.com/wesleystam/slate_serializer'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '~> 1.10'
  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
