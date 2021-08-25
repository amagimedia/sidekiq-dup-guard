# sidekiq-dup-guard

This gem prevents duplicate Sidekiq job being enqueued when already there is a job in queue with same arguments.
Uniqueness can be configured at Queue Level or at Function level

## Getting started

Include the gem in your Application Gemfile:

```
gem 'sidekiq-dup-guard'
```

```
$ bundle install

```

Or install it yourself as:

```
gem install sidekiq-dup-guard
```
## Usage

To avoid duplicate job being enqueued at Function level from `FooWorker.perform_async` until `FooWorker.new.perform` is called

```ruby
class FooWorker
  include Sidekiq::Workers

  # Only method1 and method3 should have unique jobs
  sidekiq_options :queue => :foo, :unique_methods => ['method1', 'method3']

  def perform(args)
    # Do work
  end

  def method1(args)
    # Do work
  end

  def method2(args)
    # Do work
  end

  def method3(args)
    # Do work
  end
end
```

To avoid duplicate job being enqueued at Worker level from `FooWorker.perform_async` until `FooWorker.new.perform` is called

```ruby
class FooWorker
  include Sidekiq::Workers

  # All the methods of FooWorker should have unique jobs
  sidekiq_options :queue => :foo, :unique_methods => 'all'

  def perform(args)
    # Do work
  end
end
```
