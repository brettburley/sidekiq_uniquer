require 'sidekiq_uniquer/strategies/until_and_while_executing'
require 'sidekiq_uniquer/strategies/until_executed'
require 'sidekiq_uniquer/strategies/until_executing'
require 'sidekiq_uniquer/strategies/while_executing'

module SidekiqUniquer
  module Strategies
    module_function

    def strategies
      @@strategies ||= {}
    end

    # Determines which locking strategy should be used for a given job and class.
    def from(job, worker_class)
      strategy_key = worker_class.get_sidekiq_options[JOB_STRATEGY_KEY]
      return nil if strategy_key.nil?

      strategy_class = strategies[strategy_key.to_sym]
      raise UnknownStrategy, "Unknown unique strategy #{strategy_key} for SidekiqUniquer." if strategy_class.nil?

      strategy_class.new(job)
    end

    # Registers a locking strategy. Custom locking strategies can be created and registered
    # to be used in your application.
    def register(key, klass)
      strategies[key.to_sym] = klass
    end

    register(:until_and_while_executing, UntilAndWhileExecuting)
    register(:until_executed, UntilExecuted)
    register(:until_executing, UntilExecuting)
    register(:while_executing, WhileExecuting)
  end
end
