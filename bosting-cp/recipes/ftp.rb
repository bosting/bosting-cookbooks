if node['platform'] == 'freebsd'
  package 'libsodium'
  freebsd_port 'pure-ftpd' do
    options docs: false, examples: false, largefile: true, mysql: true, pam: false, peruserlimits: true,
            scrypt: false, throttling: true, tls: false, virtualchroot: false
  end
  dest_path = '/usr/local/etc/pure-ftpd.conf'
end

if node['platform'] == 'debian'
  package 'pure-ftpd-mysql'
end

service 'pure-ftpd' do
  supports status: true, restart: true, reload: false
  action :nothing
end

pureftpd_password = generate_random_password

mysql_database_user 'pureftpd' do
  sensitive true
  connection node['bosting-cp']['mysql_connection_info']
  database_name 'bosting-cp'
  table 'pureftpd'
  privileges [:select]
  password pureftpd_password
  action :grant
  not_if { ::File.exist?(dest_path) }
end

if node['platform'] == 'freebsd'
  template '/usr/local/etc/pureftpd-mysql.conf' do
    sensitive true
    source 'pureftpd-mysql.conf.erb'
    variables(
        password: pureftpd_password
    )
    notifies :reload, 'service[pure-ftpd]'
    not_if { ::File.exist?(dest_path) }
  end

  template dest_path do
    source 'pure-ftpd.conf.erb'
    variables(
        ip: node['bosting-cp']['services_ips'].first
    )
    notifies :reload, 'service[pure-ftpd]'
  end
end

if node['platform'] == 'debian'
  # TODO
end

service 'pure-ftpd' do
  action [:enable, :start]
end
