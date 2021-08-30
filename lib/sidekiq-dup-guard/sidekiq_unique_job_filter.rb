
# Before job is enqueued this middleware will be called.
module SidekiqDupGuard
  class SidekiqUniqueJobFilter

    # get Sidekiq logger
    def logger
      Sidekiq.logger
    end

    ##
    # checks if Sidekiq Job is already present in queue
    #
    #   - If job is already present in queue then Sidekiq job will be ignored
    #   - If job is not present then Sidekiq job will be queued
    #
    # @param worker [String]: Worker class name
    # @param item [Hash]: Args passed to create a SidekiqJob
    #   - item["unique_methods"]: *all* --: All jobs enqueued to a worker should be unique
    #   - item["unique_methods"]: [array of method names] --: All jobs enqueued to a method should be unique
    # @param queue [String]:  queue name
    # @param redis_pool [ConnectionPool]: Redis connection pool
    #
    # @return nil
    #

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

    ##
    # checks if Sidekiq job is present
    #
    # @param [String] queue
    # @param [String] method
    # @param [Hash] args
    # @param [Array] ignore_keys
    #
    # @return [Boolean, String]
    #  - when job is present in queue returns true and Sidekiq job ID
    #  - when job is not present in queue returns false and nil
    def sidekiq_job_present?(queue, method, args, ignore_keys=[])
      q = Sidekiq::Queue.new(queue)
      args = args.except(*ignore_keys)
      args.transform_keys!(&:to_s)
      q.each do |j|
        if (j.args[0] == method.to_s) and (j.args[1].except(*ignore_keys) == args)
          return true, j.jid
        end
      end
      return false, nil
    end
  end
end
