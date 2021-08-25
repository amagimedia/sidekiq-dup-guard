# Configure Sidekiq Middleware

# See more: https://github.com/mperham/sidekiq/wiki/Middleware

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add SidekiqDupGuard::SidekiqUniqueJobFilter
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add SidekiqDupGuard::SidekiqUniqueJobFilter
  end
end
