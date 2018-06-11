require 'spec_helper'

RSpec.describe SidekiqUniquer::Strategies::UntilExecuting do
  include_context 'job'
  include_context 'lock mocks'

  subject(:strategy) { described_class.new(job) }

  describe '#push' do
    it 'yields if the job is locked' do
      allow(job_lock).to receive(:lock).and_return(true)
      expect { |b| strategy.push(&b) }.to yield_control
    end

    it 'does not yield if locking fails' do
      allow(job_lock).to receive(:lock).and_return(false)
      expect { |b| strategy.push(&b) }.not_to yield_control
    end
  end

  describe '#perform' do
    it 'unlocks' do
      allow(job_lock).to receive(:unlock)

      strategy.perform do
        expect(job_lock).to have_received(:unlock)
      end
    end
  end
end