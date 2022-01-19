require_relative "../lib/sidekiq-dup-guard/version"

version = SidekiqDupGuard::VERSION
abort("Git Tag and SidekiqDupGuard version doesn't match") if (ENV["CIRCLE_TAG"].sub(/^v/, "") != version)

exit(0)