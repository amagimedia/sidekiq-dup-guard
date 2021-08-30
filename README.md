# sidekiq-dup-guard

This gem provides additional Sidekiq middleware to prevent duplicate Sidekiq job's getting enqueued to the queue at the same time.
Uniqueness can be configured at Worker Level or at Function level

## Usage

### Installation

Include the gem in your Application Gemfile:

```ruby
gem 'sidekiq-dup-guard'
```
and then execute

```bash
$ bundle install
```

### Configuring at Function level

At a time there can be only one job in queue with same arguments to the method's configured in `unique_methods`.

#### Worker Example

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

This will ensure duplicate job's are not enqueued to queue from `FooWorker.perform_async` until `FooWorker.new.perform` is called for `method1` and `method3`. If a job is already present for `method1` and `method3` with same arguments then Sidekiq job will not be enqueued.

### Configuring at Worker Level

At a time there can be only one job in queue with same arguments to the all method's of a Worker.

#### Worker Example

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

This will ensure duplicate job are not enqueued to queue from `FooWorker.perform_async` until `FooWorker.new.perform` is called for all functions of `FooWorker`. If a job is already present for a method with same arguments then Sidekiq job will not be enqueued.
