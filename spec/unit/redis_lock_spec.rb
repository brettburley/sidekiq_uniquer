require 'spec_helper'

RSpec.describe SidekiqUniquer::RedisLock do
  let(:redis) { double('Redis') }

  subject(:lock) do
    described_class.new('lock-key', 'lock-value', expires: 60, timeout: 1)
  end

  before { allow(SidekiqUniquer).to receive(:redis).and_yield(redis) }

  describe '#lock' do
    describe 'inline form' do
      it 'polls until the lock is acquired' do
        set_count = 0
        allow(redis).to receive(:get).with('sidekiquniquer:lock-key').and_return(nil)
        allow(redis).to receive(:set).with('sidekiquniquer:lock-key', 'lock-value', nx: true, ex: 60) do
          (set_count += 1) >= 5
        end

        expect(lock.lock).to eq(true)
        expect(set_count).to eq(5)
      end

      it 'returns false if the lock cannot be acquired' do
        set_count = 0
        allow(redis).to receive(:get).with('sidekiquniquer:lock-key').and_return(nil)
        allow(redis).to receive(:set).with('sidekiquniquer:lock-key', 'lock-value', nx: true, ex: 60) do
          set_count += 1
          false
        end

        expect(lock.lock).to eq(false)
        expect(set_count).to be_within(1).of(11)
      end
    end

    describe 'block form' do
      it 'locks and unlocks' do
        allow(redis).to receive(:get).with('sidekiquniquer:lock-key').and_return('lock-value')
        allow(redis).to receive(:evalsha).and_return(1)

        lock.lock do
          expect(redis).not_to have_received(:evalsha)
        end

        expect(redis).to have_received(:evalsha).with('e9af4f1f90ed71fd6f5e786443b9b031ff63933f',
          keys: ['sidekiquniquer:lock-key'],
          argv: ['lock-value']
        )
      end

      it 'raises if the lock cannot be acquried' do
        allow(redis).to receive(:get).with('sidekiquniquer:lock-key').and_return(nil)
        allow(redis).to receive(:set).with('sidekiquniquer:lock-key', 'lock-value', nx: true, ex: 60)
          .and_return(false)

        block = -> { raise 'Block should not be called.' }

        expect { lock.lock(&block) }.to raise_error(SidekiqUniquer::LockTimeout)
      end
    end
  end

  describe '#unlock' do
    it 'is true when unlock is successful' do
      allow(redis).to receive(:evalsha).with('e9af4f1f90ed71fd6f5e786443b9b031ff63933f',
        keys: ['sidekiquniquer:lock-key'],
        argv: ['lock-value']
      ).and_return(1)

      expect(lock.unlock).to eq(true)
    end

    it 'is false when unlock is successful' do
      allow(redis).to receive(:evalsha).with('e9af4f1f90ed71fd6f5e786443b9b031ff63933f',
        keys: ['sidekiquniquer:lock-key'],
        argv: ['lock-value']
      ).and_return(0)

      expect(lock.unlock).to eq(false)
    end

    it 'loads the unlock lua if it is missing' do
      sha_loaded = false
      allow(redis).to receive(:evalsha) do
        raise Redis::CommandError, 'NOSCRIPT' unless sha_loaded
        1
      end
      allow(redis).to receive(:script).with(:load, anything) { sha_loaded = true }

      expect(lock.unlock).to eq(true)
      expect(sha_loaded).to eq(true)
    end
  end
end