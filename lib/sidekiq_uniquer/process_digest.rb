require 'socket'

module SidekiqUniquer
  # Generates a string to uniquely identify a node and thread that a process
  # is running in.
  class ProcessDigest
    def digest
      [hostname, process_id, thread_id].join(':')
    end

    def self.digest(*args)
      new(*args).digest
    end

    private

    def hostname
      Socket.gethostname
    end

    def process_id
      Process.pid
    end

    def thread_id
      Thread.current.object_id
    end
  end
end