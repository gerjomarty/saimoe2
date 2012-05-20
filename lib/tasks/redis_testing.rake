REDIS_DIR = Rails.root.join('spec', 'redis')
REDIS_CONF = File.join(REDIS_DIR, 'test.conf')
REDIS_PID = File.join(REDIS_DIR, 'db', 'redis.pid')
REDIS_LOCATION = ENV['REDIS_LOCATION']

namespace :redis do
  desc "Start the Redis server"
  task :start do
    redis_running = begin
      File.exists?(REDIS_PID) && Process.kill(0, File.read(REDIS_PID).to_i)
    rescue
      FileUtils.rm REDIS_PID
      false
    end

    unless redis_running
      if REDIS_LOCATION
        system "#{REDIS_LOCATION}/redis-server #{REDIS_CONF}"
      else
        system "redis-server #{REDIS_CONF}"
      end
    end
  end

  desc "Stop the Redis server"
  task :stop do
    if File.exists?(REDIS_PID)
      Process.kill 'INT', File.read(REDIS_PID).to_i
      FileUtils.rm REDIS_PID
    end
  end
end

# Start redis before the tests, and stop it after

spec_task = Rake::Task['spec']
start_task = Rake::Task['redis:start']
stop_task = Rake::Task['redis:stop']

spec_task.enhance([start_task]) do
  stop_task.invoke
end