require 'simplecov'

SimpleCov.start

require 'rspec'
require 'sidekiq/processor'
require 'sidekiq/testing'

require 'sidekiq-dup-guard'

# Dummy Sidekiq Workers

# At function level
class FooWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :foo, :unique_methods => ['demo']
end

# At Worker level
class BarWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :bar, :unique_methods => "all"
end
