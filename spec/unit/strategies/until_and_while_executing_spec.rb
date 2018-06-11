require 'spec_helper'

RSpec.describe SidekiqUniquer::Strategies::UntilAndWhileExecuting do
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
    it 'yields and unlocks if the process is locked' do
      allow(process_lock).to receive(:lock).and_yield

      expect(job_lock).to receive(:unlock)
      expect { |b| strategy.perform(&b) }.to yield_control
    end

    it 'does not yield or unlock if locking fails' do
      allow(process_lock).to receive(:lock).and_return(false)

      expect(job_lock).not_to receive(:unlock)
      expect { |b| strategy.perform(&b) }.not_to yield_control
    end

    context 'timeout is zero' do
      let(:options) { { 'lock_timeout' => 0 } }

      it 'does not raise if lock is not acquired' do
        allow(process_lock).to receive(:lock).and_raise(SidekiqUniquer::LockTimeout)

        expect(job_lock).not_to receive(:unlock)
        expect { |b| strategy.perform(&b) }.not_to yield_control
      end
    end

    context 'timeout is non-zero' do
      let(:options) { { 'lock_timeout' => 5 } }

      it 'raises if lock is not acquired' do
        allow(process_lock).to receive(:lock).and_raise(SidekiqUniquer::LockTimeout)

        expect(job_lock).not_to receive(:unlock)
        expect { |b| strategy.perform(&b) }.to raise_error(SidekiqUniquer::LockTimeout)
      end
    end
  end
end