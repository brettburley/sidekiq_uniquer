require 'sidekiq_uniquer/strategies/base'
require 'sidekiq_uniquer/strategies/until_and_while_executing'
require 'sidekiq_uniquer/strategies/until_executed'
require 'sidekiq_uniquer/strategies/until_executing'
require 'sidekiq_uniquer/strategies/while_executing'

module SidekiqUniquer
  module Strategies
    module_function

    STRATEGIES = {
      until_and_while_executing: UntilAndWhileExecuting,
      until_executed: UntilExecuted,
      until_executing: UntilExecuting,
      while_executing: WhileExecuting
    }

    def from(job, worker_class)
      strategy_key = worker_class.get_sidekiq_options[JOB_STRATEGY_KEY]
      return nil if strategy_key.nil?

      strategy_class = STRATEGIES[strategy_key.to_sym]
      raise UnknownStrategy, "Unknown unique strategy #{strategy_key} for SidekiqUniquer." if strategy_class.nil?

      strategy_class.new(job)
    end
  end
end