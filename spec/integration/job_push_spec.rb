require 'spec_helper'

require 'dummy/until_and_while_executing_worker'
require 'dummy/until_executing_worker'
require 'dummy/while_executing_worker'

describe 'job push', type: :integration do
  it 'only allows a unique job to be scheduled' do
    UntilAndWhileExecutingWorker.perform_async('job1')
    UntilAndWhileExecutingWorker.perform_async('job1')
    UntilAndWhileExecutingWorker.perform_async('job1')

    expect(UntilAndWhileExecutingWorker.jobs.count).to eq(1)
    expect(UntilAndWhileExecutingWorker.jobs.last).to include(
      'unique' => 'until_and_while_executing',
      'uniquer_digest' => a_kind_of(String)
    )
    expect(SidekiqUniquer.redis { |r| r.keys.count }).to eq(1)

    UntilAndWhileExecutingWorker.drain

    expect(UntilAndWhileExecutingWorker.jobs.count).to eq(0)
    expect(SidekiqUniquer.redis { |r| r.keys.count }).to eq(0)

    # Ensure that locks are properly released and that we can schedule
    # another job with matching arguments.
    UntilAndWhileExecutingWorker.perform_async('job1')

    expect(UntilAndWhileExecutingWorker.jobs.count).to eq(1)
    expect(SidekiqUniquer.redis { |r| r.keys.count }).to eq(1)
  end

  it 'allows different arguments to be scheduled' do
    UntilAndWhileExecutingWorker.perform_async('job1')
    UntilAndWhileExecutingWorker.perform_async('job2')
    UntilAndWhileExecutingWorker.perform_async('job3')

    expect(UntilAndWhileExecutingWorker.jobs.count).to eq(3)
    expect(SidekiqUniquer.redis { |r| r.keys.count }).to eq(3)

    UntilAndWhileExecutingWorker.drain

    expect(UntilAndWhileExecutingWorker.jobs.count).to eq(0)
    expect(SidekiqUniquer.redis { |r| r.keys.count }).to eq(0)
  end

  it 'allows many while_executing jobs to be scheduled' do
    WhileExecutingWorker.perform_async('job1')
    WhileExecutingWorker.perform_async('job1')
    WhileExecutingWorker.perform_async('job1')

    expect(WhileExecutingWorker.jobs.count).to eq(3)
    expect(WhileExecutingWorker.jobs.last).to include(
      'unique' => 'while_executing',
      'uniquer_digest' => a_kind_of(String)
    )
    expect(SidekiqUniquer.redis { |r| r.keys.count }).to eq(0)
  end

  it 'extends the lock expiration if scheduled' do
    UntilExecutingWorker.perform_in(60, 'job1')

    expect(SidekiqUniquer.redis { |r| r.keys.count }).to eq(1)
    expect(SidekiqUniquer.redis { |r| r.ttl(r.keys.first) }).to be_within(1).of(70)
  end
end