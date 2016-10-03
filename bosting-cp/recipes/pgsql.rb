pgsql_version_short = node['bosting-cp']['pgsql_version'].sub('.', '')

if node['platform'] == 'freebsd'
  package "postgresql#{pgsql_version_short}-server"

  append_if_no_line "set PostgreSQL data dir" do
    path '/etc/rc.conf'
    line 'postgresql_data="/var/db/pgsql/data"'
    notifies :restart, 'service[postgresql]'
  end

  directory '/var/db/pgsql' do
    owner 'pgsql'
    group 'pgsql'
    mode 0755
  end

  execute 'service postgresql oneinitdb' do
    creates '/var/db/pgsql/data/PG_VERSION'
  end
end

if pgsql_version_short.to_i >= 93
  unix_socket_directories = ['/tmp'].
   concat(node['bosting-cp']['apache_variations'].keys.map{ |name| "/usr/jails/#{name}/tmp" }).join(',')

  replace_or_add "set PostgreSQL socket directories" do
    path '/var/db/pgsql/data/postgresql.conf'
    pattern 'unix_socket_directories'
    line "unix_socket_directories = '#{unix_socket_directories}'\t# comma-separated list of directories"
    notifies :restart, 'service[postgresql]'
  end
else
  # TODO: It does not support multiple sockets, use `unix_socket_directory` and link manually to all jails
  raise 'PostgreSQL versions lower than 9.3 are not yet supported'
end

service 'postgresql' do
  supports status: true, restart: true, reload: false
  action [:enable, :start]
end

username = node['platform'] == 'freebsd' ? 'pgsql' : 'postgres'

execute 'set PostgreSQL root password' do
  sensitive true
  sql = "ALTER USER #{username} WITH PASSWORD '#{node['bosting-cp']['pgsql_root_password']}';"
  command "echo \"#{sql}\" | psql -U #{username} template1"
  not_if { ::File.exist?('/root/.pgpass') }
end

template '/root/.pgpass' do
  sensitive true
  source 'pgpass.erb'
  mode 0600
  variables(
    username: username,
    password: node['bosting-cp']['pgsql_root_password']
  )
end

replace_or_add 'Set md5 authentication method for sockets' do
  path '/var/db/pgsql/data/pg_hba.conf'
  pattern "local.*all.*all.*trust"
  line "local\tall\tall\tmd5"
  notifies :restart, 'service[postgresql]'
end

replace_or_add 'Set md5 authentication method for IPv4 local connections' do
  path '/var/db/pgsql/data/pg_hba.conf'
  pattern "host.*all.*all.*127\.0\.0\.1/32.*trust"
  line "host\tall\tall\t127.0.0.1/32\tmd5"
  notifies :restart, 'service[postgresql]'
end

replace_or_add 'Set md5 authentication method for IPv6 local connections' do
  path '/var/db/pgsql/data/pg_hba.conf'
  pattern "host.*all.*all.*::1/128.*trust"
  line "host\tall\tall\t::1/128\tmd5"
  notifies :restart, 'service[postgresql]'
end

chef_gem 'pg' do
  compile_time false
end
