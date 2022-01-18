require_relative "lib/sidekiq-dup-guard/version"

version = SidekiqDupGuard::VERSION
version = ENV['CIRCLE_TAG'].sub(/^v/, "") if !ENV['CIRCLE_TAG'].nil?

Gem::Specification.new do |spec|
  spec.name        = 'example'
  spec.version     = version
  spec.summary     = "Sidekiq middleware to prevent enqueue of duplicate jobs"
  spec.description = <<-EOS
    This gem provides a Sidekiq middleware to prevent duplicate jobs from getting enqueued to the queue.
  EOS
  spec.authors     = ["Sowmya S K"]
  spec.email       = ['cloudport.team@amagi.com']
  spec.homepage    = "https://github.com/amagimedia/sidekiq-dup-guard"
  spec.license     = "MIT"
  spec.files       = ["sidekiq-dup-guard.gemspec", "README.md", "CHANGELOG.md", "LICENSE"] #+ `git ls-files | grep -E '^(lib)'`.split("\n")

  spec.add_dependency 'sidekiq'
end
