workers 2
worker_timeout 600
threads 2,2
shared_dir = '/tmp'
bind "unix://#{shared_dir}/sockets/puma.sock"


