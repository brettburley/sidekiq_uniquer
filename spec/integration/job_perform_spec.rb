require 'spec_helper'
require 'dummy/while_executing_worker'

describe 'job perform', type: :integration do
  it 'only runs one job' do
    WhileExecutingWorker.perform_async('job1')
    WhileExecutingWorker.perform_async('job1')
    WhileExecutingWorker.perform_async('job1')

    expect(WhileExecutingWorker.jobs.count).to eq(3)

    # Since default timeout is zero, the other jobs should silently
    # be skipped without waiting.
    3.times.map do
      Thread.new { WhileExecutingWorker.perform_one }
    end.each(&:join)

    expect(WhileExecutingWorker.run_count).to eq(1)
    expect(WhileExecutingWorker.jobs.count).to eq(0)
  end

  it 'can run jobs sequentially' do
    WhileExecutingWorker.perform_async('job1')
    WhileExecutingWorker.perform_async('job1')

    expect(WhileExecutingWorker.jobs.count).to eq(2)

    # When run sequentially, the locks should be released between each.
    WhileExecutingWorker.perform_one
    WhileExecutingWorker.perform_one

    expect(WhileExecutingWorker.run_count).to eq(2)
    expect(WhileExecutingWorker.jobs.count).to eq(0)
  end

  it 'runs multiple jobs with different arguments' do
    WhileExecutingWorker.perform_async('job1')
    WhileExecutingWorker.perform_async('job2')
    WhileExecutingWorker.perform_async('job3')

    expect(WhileExecutingWorker.jobs.count).to eq(3)

    3.times.map do
      Thread.new { WhileExecutingWorker.perform_one }
    end.each(&:join)

    expect(WhileExecutingWorker.run_count).to eq(3)
    expect(WhileExecutingWorker.jobs.count).to eq(0)
  end

  it 'runs jobs after the lock expires' do
    WhileExecutingWorker.set('lock_timeout' => 1.5).perform_async('job1')
    WhileExecutingWorker.set('lock_timeout' => 1.5).perform_async('job1')
    WhileExecutingWorker.set('lock_timeout' => 1.5).perform_async('job1')

    expect(WhileExecutingWorker.jobs.count).to eq(3)

    # Since each job takes 1 second to perform, 2 jobs should be completed,
    # and one job should timeout waiting for a lock.
    expect do
      3.times.map do
        Thread.new { WhileExecutingWorker.perform_one }
      end.each(&:join)
    end.to raise_error(SidekiqUniquer::LockTimeout)

    expect(WhileExecutingWorker.run_count).to eq(2)
    expect(WhileExecutingWorker.jobs.count).to eq(0)
  end
end