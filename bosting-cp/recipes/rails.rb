home = node['bosting-cp']['rails']['home']
site_home = node['bosting-cp']['rails']['site_home']
user = node['bosting-cp']['rails']['user']
group = node['bosting-cp']['rails']['group']

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

directory "#{home}/.rails-vars" do
  owner user
  group group
  mode 0700
end

template "#{home}/.rails-vars/bosting.sh" do
  source 'rails-vars.sh.erb'
  variables(
    lazy {
      {
        secret_base: generate_rails_secret,
        redis_password: ::File.read('/root/redis_password').strip
      }
    }
  )
  owner user
  group group
  mode 0600
end

template '/usr/local/etc/rc.d/unicorn_bosting' do
  source 'unicorn_bosting_init.erb'
  mode 0750
end

service 'unicorn_bosting' do
  supports(restart: true, reload: true, status: true)
  action :enable
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
  notifies :run, 'rails_command[db_migrate]'
  notifies :run, 'rails_command[assets_precompile]'
  notifies :reload, 'service[unicorn_bosting]'
end

include_recipe 'ruby_build'
include_recipe 'ruby_rbenv::system'

execute 'compile dynamic bash extension to speed up rbenv' do
  cwd '/usr/local/rbenv/src'
  command './configure && make'
  creates '/usr/local/rbenv/libexec/rbenv-realpath.dylib'
end

rails_command 'set bundler jobs' do
  command "bundle config --global jobs #{node['bosting-cp']['cores'].to_s}"
end

rails_command 'bundle install' do
  command 'bundle install --without development test --deployment'
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
mysql_password = generate_random_password

template "#{home}/.my.cnf" do
  sensitive true
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
  sensitive true
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
  sensitive true
  source 'seeds.rb.erb'
  mode 0600
  owner user
  group group
  notifies :run, 'rails_command[db_seed]'
end

rails_command 'db_setup' do
  command './bin/rake db:setup'
  not_if "mysql bosting-cp -e 'SHOW TABLES'"
end

rails_command 'db_migrate' do
  command './bin/rake db:migrate'
  action :nothing
end

rails_command 'db_seed' do
  sensitive true
  command './bin/rake db:seed'
  action :nothing
end

rails_command 'assets_precompile' do
  command './bin/rake assets:precompile'
  action :nothing
end

service 'unicorn_bosting' do
  action :start
end

template '/usr/local/etc/nginx/vhosts.rails/bosting.conf' do
  source 'vhost_bosting.conf.erb'
  variables(
      nginx_conf_base: node['bosting-cp']['nginx_conf_base'],
      panel_domain: node['bosting-cp']['panel_domain'],
      https: node['bosting-cp']['panel_ssl']
  )
  notifies :reload, 'service[nginx]'
end
