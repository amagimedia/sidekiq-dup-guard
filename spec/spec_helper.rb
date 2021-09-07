require 'simplecov'

SimpleCov.start

SimpleCov.minimum_coverage 100

require 'rspec'
require 'sidekiq/processor'
require 'sidekiq/testing'

require 'sidekiq-dup-guard'

# Dummy Sidekiq Workers

# At function level
class FooWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :foo, :dup_guard_methods => ['demo']
end

# At Worker level
class BarWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :bar, :dup_guard_methods => "all"
end
