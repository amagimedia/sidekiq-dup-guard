module SidekiqDupGuard
  class SidekiqUniqueJobFilter

    # Get Sidekiq logger
    def logger
      Sidekiq.logger
    end

    # Before job is enqueued this middleware will be called

    # @param [String] worker
    # @param [Hash] item
    # @param [String] queue queue name
    # @param [Redis] redis_pool => check type once

    # @return nil
    #   - item["unique_methods"] = all => All jobs submitted to this queue should be unique
    #   - item["unique_methods"] = [array of method names] => All jobs submitted to this method should be unique
    #   - If job is already present in queue then Sidekiq job will be ignored
    #   - If job is not present then Sidekiq job will be queued

    def call(worker, item, queue, redis_pool)
      if item["unique_methods"].present? and (item["unique_methods"] == "all" or item["unique_methods"].include?(item["args"][0]))
        status, jid = sidekiq_job_present?(queue, item["args"][0], item["args"][1])
        if status
          logger.info("SidekiqUniqueJobFilter#call: #{item["class"]}##{item["args"][0]} '#{item["args"][1]}' job already exists in queue as JID-#{jid}. Skipping enqueuing")
          return
        end
      end

      yield
    end

    # Checks if Sidekiq job is present

    # @param [String] queue
    # @param [String] method
    # @param [Hash] args
    # @param [Array] ignore_keys

    # @return [Boolean, String]
    #  - when job is present in queue returns true and Sidekiq job ID
    #  - when job is not present in queue returns false and nil
    def sidekiq_job_present?(queue, method, args, ignore_keys=[])
      q = Sidekiq::Queue.new(queue)
      args = args.except(*ignore_keys)
      q.each do |j|
        if (j.args[0] == method.to_s) and (j.args[1].except(*ignore_keys) == args)
          return true, j.jid
        end
      end
      return false, nil
    end
  end
end
