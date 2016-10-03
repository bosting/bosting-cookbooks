home = '/home/bosting'
site_home = home + '/bosting-cp'
user = 'bosting'
group = 'www'
nginx_conf_base = node['bosting-cp']['nginx_conf_base']
ruby_env_vars = {
    'RAILS_ENV' => 'production',
    'PATH' => "/usr/local/rbenv/shims:#{ENV['PATH']}",
    'HOME' => home # Needed to find .my.cnf in home directory
}

template '/usr/local/etc/rc.d/unicorn_bosting' do
  source 'unicorn_bosting_init.erb'
  mode 0750
end

service 'unicorn_bosting' do
  supports(restart: true, reload: true, status: true)
  action :enable
end

user 'bosting' do
  group 'webuser'
  home home
  shell '/usr/local/bin/zsh'
end

directory home do
  owner user
  group group
  mode 0750
end

directory "#{home}/.ssh" do
  owner user
  group group
  mode 0700
end

ssh_known_hosts_entry 'github.com' do
  key 'github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=='
end

git 'bosting-cp' do
  repository 'git://github.com/bosting/bosting-cp.git'
  destination site_home
  user user
  group group
  notifies :run, 'execute[db_migrate]'
  notifies :run, 'execute[assets_precompile]'
  notifies :reload, 'service[unicorn_bosting]'
end

include_recipe 'ruby_build'
include_recipe 'ruby_rbenv::system'

execute 'compile dynamic bash extension to speed up rbenv' do
  cwd '/usr/local/rbenv/src'
  command './configure && make'
  creates '/usr/local/rbenv/libexec/rbenv-realpath.dylib'
end

execute 'set bundler jobs' do
  command "bundle config --global jobs #{node['bosting-cp']['cores'].to_s}"
  cwd home
  environment('HOME' => home)
  user user
  group group
end

execute 'bundle install --without development test --deployment' do
  cwd site_home
  user user
  group group
  environment(ruby_env_vars)
  not_if 'bundle check', cwd: site_home
end

template "#{home}/.zshrc" do
  source 'zshrc.erb'
  owner user
  group group
end

template "#{site_home}/config/settings.yml" do
  source 'settings.yml.erb'
  owner user
  group group
  notifies :reload, 'service[unicorn_bosting]'
end

dest_path = "#{site_home}/config/database.yml"
mysql_password = generate_random_password(16)

template "#{home}/.my.cnf" do
  source 'my.cnf.erb'
  mode 0600
  owner user
  group group
  variables(
      user: 'bosting-cp',
      password: mysql_password
  )
  not_if { ::File.exist?(dest_path) }
end

mysql_database_user 'bosting-cp' do
  connection node['bosting-cp']['mysql_connection_info']
  database_name 'bosting-cp'
  privileges [:all]
  password mysql_password
  action :grant
  not_if { ::File.exist?(dest_path) }
end

template dest_path do
  sensitive true
  source 'database.yml.erb'
  variables password: mysql_password
  mode 0600
  owner user
  group group
  not_if { ::File.exist?(dest_path) }
end

smtp_settings = symbolize_keys(
    {
        delivery_method: node['bosting-cp']['delivery_method'].to_sym,
        smtp_settings: node['bosting-cp']['smtp_settings'].to_hash
    })

template "#{site_home}/config/email.yml" do
  source 'email.yml.erb'
  mode 0600
  owner user
  group group
  variables(settings: smtp_settings.to_yaml)
  notifies :reload, 'service[unicorn_bosting]'
end

template "#{site_home}/db/seeds.rb" do
  source 'seeds.rb.erb'
  mode 0600
  owner user
  group group
  notifies :run, 'execute[db_seed]'
end

execute './bin/rake db:setup' do
  cwd site_home
  user user
  group group
  environment(ruby_env_vars)
  not_if "mysql bosting-cp -e 'SHOW TABLES'"
end

execute 'db_migrate' do
  command './bin/rake db:migrate'
  cwd site_home
  user user
  group group
  environment(ruby_env_vars)
  action :nothing
end

execute 'db_seed' do
  command './bin/rake db:seed'
  cwd site_home
  user user
  group group
  environment(ruby_env_vars)
  action :nothing
end

execute 'assets_precompile' do
  command './bin/rake assets:precompile'
  cwd site_home
  user user
  group group
  environment(ruby_env_vars)
  action :nothing
end

service 'unicorn_bosting' do
  action :start
end

template '/usr/local/etc/nginx/vhosts.rails/bosting.conf' do
  source 'vhost_bosting.conf.erb'
  variables(
      nginx_conf_base: nginx_conf_base,
      panel_domain: node['bosting-cp']['panel_domain'],
      https: node['bosting-cp']['panel_ssl']
  )
  notifies :reload, 'service[nginx]'
end
