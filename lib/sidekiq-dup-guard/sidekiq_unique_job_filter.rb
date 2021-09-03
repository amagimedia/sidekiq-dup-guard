
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
    #   - If job is already present in queue with same arguments then Sidekiq job will be ignored
    #   - If job is not present with similar arguments then Sidekiq job will be queued
    #
    # @param worker [String]: Worker class name
    # @param item [Hash]: Args passed to create a SidekiqJob
    #   - item["dup_guard_methods"]: *all* --: All jobs enqueued to all the function of a worker should be unique
    #   - item["dup_guard_methods"]: [array of method names] --: All jobs enqueued to a method should be unique
    # @param queue [String]:  queue name
    # @param redis_pool [ConnectionPool]: Redis connection pool
    #
    # @return nil
    #

    def call(worker, item, queue, redis_pool)
      if (item["dup_guard_methods"] != nil) and !item["dup_guard_methods"].empty? and (item["dup_guard_methods"] == "all" or item["dup_guard_methods"].include?(item["args"][0]))
        status, jid = sidekiq_job_present?(queue, item["args"][0], item["args"][1])
        if status
          logger.info("SidekiqDupGuard: #{item["class"]}##{item["args"][0]} '#{item["args"][1]}' job already exists in queue with JID #{jid}, skipping enqueue.")
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
    #
    # @return [Boolean, String]
    #  - when job is present in queue returns true and Sidekiq job ID
    #  - when job is not present in queue returns false and nil
    def sidekiq_job_present?(queue, method, args)
      q = Sidekiq::Queue.new(queue)
      args.transform_keys!(&:to_s)
      q.each do |j|
        if (j.args[0] == method.to_s) and (j.args[1] == args)
          return true, j.jid
        end
      end
      return false, nil
    end
  end
end
