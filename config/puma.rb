# frozen_string_literal: true

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `environment` that Puma will run in.
#
ENVIRONMENT = ENV.fetch('RAILS_ENV', 'development')
environment ENVIRONMENT

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
PORT = ENV.fetch('PORT', 3000)

if ENVIRONMENT == 'development'
  ssl_bind 'localhost', PORT, {
    cert: ENV.fetch('RAILS_SSL_CRT') { File.join(Dir.pwd, 'localhost%2B2.pem') },
    key: ENV.fetch('RAILS_SSL_KEY') { File.join(Dir.pwd, 'localhost%2B2-key.pem') },
    verify_mode: 'none'
  }
else
  port PORT
end

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
# preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
