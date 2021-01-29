
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "order_by_ids/version"

Gem::Specification.new do |spec|
  spec.name          = "order_by_ids"
  spec.version       = OrderByIds::VERSION
  spec.authors       = ["Makoto Shimoda"]
  spec.email         = ["kotoshimoda@gmail.com"]

  spec.summary       = %q{`OrderByIds` adds the ability to order `ActiveRecord` by an array of Id`s}
  spec.homepage      = "https://makotoshimoda.github.io/"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
