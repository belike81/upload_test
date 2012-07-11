# define paths and filenames
deploy_to = "/home/deployer/apps/upload_test"
pid_file = "#{deploy_to}/shared/pids/unicorn.pid"
err_log = "#{deploy_to}/log/unicorn.log"
log_file = "#{deploy_to}/log/unicorn.log"
old_pid = pid_file + '.oldbin'

timeout 30
worker_processes 2 # increase or decrease

working_directory "#{deploy_to}/current"
pid pid_file
stderr_path err_log
stdout_path log_file
listen "/tmp/unicorn.upload_test.sock"
