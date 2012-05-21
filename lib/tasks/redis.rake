REDIS_LOCATION = ENV['REDIS_LOCATION']

def redis_conf
  Rails.root.join('config', 'redis', "#{Rails.env.to_s.downcase}.conf")
end

def redis_pid
  Rails.root.join('db', 'redis', "#{Rails.env.to_s.downcase}.pid")
end

namespace :redis do
  desc "Start the Redis server"
  task :start => :environment do
    redis_running = begin
      File.exists?(redis_pid) && Process.kill(0, File.read(redis_pid).to_i)
    rescue
      FileUtils.rm redis_pid
      false
    end

    unless redis_running
      if REDIS_LOCATION
        system "#{REDIS_LOCATION}/redis-server #{redis_conf}"
      else
        system "redis-server #{redis_conf}"
      end
    end
  end

  desc "Stop the Redis server"
  task :stop => :environment do
    if File.exists?(redis_pid)
      Process.kill 'INT', File.read(redis_pid).to_i
      FileUtils.rm redis_pid
    end
  end
end

desc "Force Rails env to be 'test'"
task :force_test_env => :environment do
  Rails.env = 'test'
end

force_test_env = Rake::Task['force_test_env']
spec_task = Rake::Task['spec']
start_task = Rake::Task['redis:start']
stop_task = Rake::Task['redis:stop']

# Before running the specs, force the test env to be 'test' and start the Redis server
# After running the specs, stop the Redis server

spec_task.enhance([force_test_env, start_task]) do
  stop_task.invoke
end