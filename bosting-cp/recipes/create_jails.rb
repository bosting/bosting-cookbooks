include_recipe 'jail'

chef_install_method = node['bosting-cp']['chef_install_method']

directory '/etc/ssh/users' do
  mode 0700
end
template '/etc/ssh/users/sshd_config'
include_recipe 'bosting-cp::sshd_config'

ssh_keygen '/root/.ssh/chef_rsa' do
  owner 'root'
  group 'wheel'
  secure_directory true
end

dest_path = '/usr/local/bin/notify_chef'
template dest_path do
  mode 0700
  variables(apache_variation_names: node['bosting-cp']['apache_variations'].map(&:first))
end

sudo 'notify_chef' do
  user 'bosting'
  runas 'root'
  nopasswd true
  commands [dest_path]
end

directory '/var/run/shared' do
  mode 01777
end

link '/tmp/mysql.sock' do
  to '/var/run/shared/mysql.sock'
end

node['bosting-cp']['apache_variations'].each do |jail_name, options|
  jail_base_path = "/usr/jails/#{jail_name}"

  jail jail_name do
    ipaddress options['ip']
    action :create
  end

  file "#{jail_base_path}/etc/bosting_name" do
    content jail_name
    mode 0600
  end

  dest_path = "#{jail_base_path}/etc/resolv.conf"
  execute "cp /etc/resolv.conf #{dest_path}" do
    creates dest_path
  end

  add_nullfs_to_jail('/usr/home', jail_name)
  link("#{jail_base_path}/home") { to '/usr/home' }
  add_nullfs_to_jail('/opt/chef', jail_name) if chef_install_method == 'omnitruck'

  dest_path = "#{jail_base_path}/usr/ports"
  link(dest_path) do
    ignore_failure true
    action :delete
  end
  add_nullfs_to_jail('/usr/ports', jail_name)

  directory "#{jail_base_path}/root/.ssh" do
    mode 0700
  end

  dest_path = "#{jail_base_path}/root/.ssh/authorized_keys"
  file dest_path do
    mode 0600
  end

  append_if_no_line "add chef ssh key to #{jail_name} jail" do
    path dest_path
    line lazy { ::File.read('/root/.ssh/chef_rsa.pub').strip }
  end

  append_if_no_line "enable ssh server in #{jail_name} jail" do
    path "#{jail_base_path}/etc/rc.conf"
    line 'sshd_enable="YES"'
  end

  replace_or_add 'allow root login without password' do
    path "#{jail_base_path}/etc/ssh/sshd_config"
    pattern 'PermitRootLogin'
    line 'PermitRootLogin without-password'
  end

  add_nullfs_to_jail('/var/run/shared', jail_name)
  link "#{jail_base_path}/tmp/mysql.sock" do
    to '/var/run/shared/mysql.sock'
  end

  jail(jail_name) do
    action :start
    notifies :reload, 'service[pf]'
  end
end
