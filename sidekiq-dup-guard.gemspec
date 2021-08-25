require_relative "lib/sidekiq-dup-guard/version"

Gem::Specification.new do |spec|
  spec.name        = 'sidekiq-dup-guard'
  spec.version     = SidekiqDupGuard::VERSION
  spec.summary     = "Sidekiq Middleware which prevents duplicate jobs enqueued"
  spec.description = "Sidekiq Middleware which prevents duplicate jobs enqueued"
  spec.authors     = ["Sowmya S K"]
  spec.email       = ['cloudport.team@amagi.com']
  spec.homepage    = "https://github.com/amagimedia/sidekiq-dup-guard"
  spec.license     = "Apache-2.0"
  spec.files       = ["sidekiq-dup-guard.gemspec", "README.md", "CHANGELOG.md", "LICENSE"] + `git ls-files | grep -E '^(lib)'`.split("\n")

  spec.add_dependency 'sidekiq'
end
