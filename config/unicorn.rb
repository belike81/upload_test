deploy_to = "/home/deployer/apps/upload_test"
working_directory "#{deploy_to}/current"
pid "#{deploy_to}/shared/pids/unicorn.pid"
stderr_path "#{deploy_to}/shared/log/unicorn.log"
stdout_path "#{deploy_to}/shared/log/unicorn.log"
listen "/tmp/unicorn.upload_test.sock"

timeout 30
worker_processes 2 # increase or decrease
