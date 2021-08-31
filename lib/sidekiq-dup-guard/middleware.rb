# Configure Sidekiq Middleware

# Sidekiq Wiki for more info: https://github.com/mperham/sidekiq/wiki/Middleware

# :nocov:
Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add SidekiqDupGuard::SidekiqUniqueJobFilter
  end
end
# :nocov:

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add SidekiqDupGuard::SidekiqUniqueJobFilter
  end
end
