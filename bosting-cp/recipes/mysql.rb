if node['platform'] == 'freebsd'
  package "mysql#{node['bosting-cp']['mysql_version'].sub('.', '')}-server"

  service 'mysql' do
    service_name 'mysql-server'
    supports status: true, restart: true, reload: false
    action [:enable, :start]
  end
end

if node['platform'] == 'debian'
  package 'mysql-server'
end

execute 'set mysql root password' do
  sensitive true
  sql = %W(
    USE mysql;
    DELETE FROM user;
    DELETE FROM db;
    CREATE USER 'root'@'%' IDENTIFIED BY '#{node['bosting-cp']['mysql_root_password']}';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
    DROP DATABASE IF EXISTS test;
    FLUSH PRIVILEGES;
  )
  command "echo \"#{sql.join(' ')}\" | mysql"
  not_if { ::File.exist?('/root/.my.cnf') }
end

template '/root/.my.cnf' do
  source 'my.cnf.erb'
  mode 0600
  variables(
      user: 'root',
      password: node['bosting-cp']['mysql_root_password']
  )
end
