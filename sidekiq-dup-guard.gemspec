require_relative "lib/sidekiq-dup-guard/version"

Gem::Specification.new do |spec|
  spec.name        = 'sidekiq-dup-guard'
  spec.version     = SidekiqDupGuard::VERSION
  spec.summary     = "Sidekiq Middleware to prevent enqueue of duplicate jobs"
  spec.description = <<-EOS
    This gem provides additional Sidekiq middleware to prevent duplicate Sidekiq job's getting enqueued to the queue at the same time.
  EOS
  spec.authors     = ["Sowmya S K"]
  spec.email       = ['cloudport.team@amagi.com']
  spec.homepage    = "https://github.com/amagimedia/sidekiq-dup-guard"
  spec.license     = "Apache-2.0"
  spec.files       = ["sidekiq-dup-guard.gemspec", "README.md", "CHANGELOG.md", "LICENSE"] + `git ls-files | grep -E '^(lib)'`.split("\n")

  spec.add_dependency 'sidekiq'
end
