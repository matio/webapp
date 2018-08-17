worker_processes 2
timeout ENV['RAILS_ENV'] == 'production' ? 15 : 999999999
preload_app true

listen 3000
pid '/tmp/unicorn.pid'

# if ENV['RAILS_ENV'] == 'production'
#   stderr_path File.expand_path('log/unicorn-stderr.log', ENV['RAILS_ROOT'])
#   stdout_path File.expand_path('log/unicorn-stdout.log', ENV['RAILS_ROOT'])
# end

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
