require 'spec_helper'

RSpec.describe SidekiqUniquer::Strategies::WhileExecuting do
  include_context 'job'
  include_context 'lock mocks'

  subject(:strategy) { described_class.new(job) }

  describe '#push' do
    it 'yields' do
      expect { |b| strategy.push(&b) }.to yield_control
    end
  end

  describe '#perform' do
    it 'yields and unlocks if the process is locked' do
      allow(process_lock).to receive(:lock).and_yield
      expect { |b| strategy.perform(&b) }.to yield_control
    end

    it 'does not yield or unlock if locking fails' do
      allow(process_lock).to receive(:lock).and_return(false)
      expect { |b| strategy.perform(&b) }.not_to yield_control
    end

    context 'timeout is zero' do
      let(:options) { { 'lock_timeout' => 0 } }

      it 'does not raise if lock is not acquired' do
        allow(process_lock).to receive(:lock).and_raise(SidekiqUniquer::LockTimeout)
        expect { |b| strategy.perform(&b) }.not_to yield_control
      end
    end

    context 'timeout is non-zero' do
      let(:options) { { 'lock_timeout' => 5 } }

      it 'raises if lock is not acquired' do
        allow(process_lock).to receive(:lock).and_raise(SidekiqUniquer::LockTimeout)
        expect { |b| strategy.perform(&b) }.to raise_error(SidekiqUniquer::LockTimeout)
      end
    end
  end
end