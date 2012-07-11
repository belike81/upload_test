# define paths and filenames
deploy_to = "/home/deployer/apps/upload_test"
pid_file = "#{deploy_to}/shared/pids/unicorn.pid"
socket_file= "/tmp/unicorn.upload_test.sock"
err_log = "#{deploy_to}/log/unicorn.log"
log_file = "#{deploy_to}/log/unicorn.log"
old_pid = pid_file + '.oldbin'

timeout 30
worker_processes 2 # increase or decrease

working_directory "#{deploy_to}/current"
pid pid_file
stderr_path err_log
stdout_path log_file
listen socket_file, :backlog => 1024

# make forks faster
preload_app true

# make sure that Bundler finds the Gemfile
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', File.dirname(__FILE__))
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!

  # zero downtime deploy magic:
  # if unicorn is already running, ask it to start a new process and quit.
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|

  # re-establish activerecord connections.
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection
end
