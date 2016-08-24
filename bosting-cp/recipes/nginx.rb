nginx_conf_base = node['bosting-cp']['nginx_conf_base']

tmp_path = '/var/tmp/nginx'
dhparam_path = nginx_conf_base + '/ssl/dhparam.pem'

service 'nginx' do
  supports(restart: true, reload: true, status: true)
  action :enable
end

directory nginx_conf_base do
  mode 0750
end

directory '/var/log/nginx' do
  mode 0750
  owner 'www'
  group 'www'
end


directory tmp_path do
  mode 0750
  owner 'www'
  group 'www'
end

%w(ssl vhosts vhosts.rails vhosts.ssl vhosts.static).each do |dir|
  directory "#{nginx_conf_base}/#{dir}" do
    mode 0750
  end
end

template "#{nginx_conf_base}/nginx.conf" do
  source 'nginx.conf.erb'
  variables(
      nginx_conf_base: nginx_conf_base,
      error_log_path: '/var/log/nginx/error_log',
      tmp_path: tmp_path
  )
  notifies :reload, 'service[nginx]'
end

execute 'generate dhparam.pem for nginx' do
  command "openssl dhparam -out #{dhparam_path} 2048"
  creates dhparam_path
end

template "#{nginx_conf_base}/ssl.conf" do
  source 'ssl.conf.erb'
  variables(
      dhparam_path: dhparam_path
  )
  notifies :reload, 'service[nginx]'
end

cookbook_file "#{nginx_conf_base}/custom_mime.types" do
  source 'custom_mime.types'
  notifies :reload, 'service[nginx]'
end

template "#{nginx_conf_base}/default.conf" do
  source 'nginx_default.conf.erb'
  notifies :reload, 'service[nginx]'
end

directory '/usr/local/www/empty_page' do
  recursive true
end

cookbook_file "/usr/local/www/empty_page/index.html" do
  source 'empty_page.html'
end

service 'nginx' do
  action :start
end
