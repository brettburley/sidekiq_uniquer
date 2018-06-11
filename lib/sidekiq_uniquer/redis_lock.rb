module SidekiqUniquer
  class RedisLock
    attr_reader :key, :value, :expires, :timeout

    # Creates a lock in redis.
    #
    # @param key [String] a unique key for the lock
    # @param value [String] a value for the lock that should be unique (a JobDigest or ProcessDigest string)
    # @param expires [Integer] the number of seconds that the lock should expire in Redis if it is not unlocked
    # @param timeout [Integer] the number of seconds to wait to acquire the lock (nil waits forever, 0 does not wait)
    def initialize(key, value, expires:, timeout:)
      @key = key
      @value = value
      @expires = expires
      @timeout = timeout
    end

    # Locks this lock in redis.
    # @yield When passed a block, it will automatically unlock at the end of the block, even if the
    #       block raises.
    def lock
      locked = acquire_lock

      if block_given?
        raise LockTimeout unless locked
        begin
          return yield
        ensure
          unlock
        end
      end

      locked
    end

    # Unlocks this lock in redis.
    def unlock
      result =
        SidekiqUniquer.redis do |conn|
          begin
            conn.evalsha(unlock_lua_sha, keys: [namespaced_key], argv: [value])
          rescue Redis::CommandError => e
            raise unless e.message =~ /\ANOSCRIPT/
            SidekiqUniquer.logger.debug "SidekiqUniquer loading lua unlock script"
            conn.script(:load, unlock_lua)
            conn.evalsha(unlock_lua_sha, keys: [namespaced_key], argv: [value])
          end
        end

      SidekiqUniquer.logger.debug "SidekiqUniquer unlocked lock #{key}" if result == 1

      result == 1
    end

    private

    def acquire_lock
      locked = false
      start_at = Time.now

      loop do
        locked = SidekiqUniquer.redis do |conn|
          conn.get(namespaced_key) == value || conn.set(namespaced_key, value, nx: true, ex: expires)
        end
        break if locked || (!timeout.nil? && Time.now - start_at > timeout)
        sleep 0.1
      end

      SidekiqUniquer.logger.debug "SidekiqUniquer acquired lock #{key}" if locked

      locked
    end

    def namespaced_key
      "#{REDIS_PREFIX}:#{key}"
    end

    def unlock_lua
      <<-LUA.strip
      if redis.call("get", KEYS[1]) == ARGV[1] then
          return redis.call("del", KEYS[1])
      else
          return 0
      end
      LUA
    end

    def unlock_lua_sha
      Digest::SHA1.hexdigest(unlock_lua)
    end
  end
end
