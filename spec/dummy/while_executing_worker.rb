class WhileExecutingWorker
  include Sidekiq::Worker

  sidekiq_options unique: :while_executing

  @mutex = Mutex.new
  @run_count = 0

  def perform(id)
    self.class.increment_count
    sleep 1
  end

  def self.increment_count
    @mutex.synchronize do
      @run_count += 1
    end
  end

  def self.reset_count
    @mutex.synchronize do
      @run_count = 0
    end
  end

  def self.run_count
    @run_count
  end
end
