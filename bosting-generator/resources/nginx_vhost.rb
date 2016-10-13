resource_name :nginx_vhost

property :server_name, String, name_property: true
property :user, String, required: true
property :ip, String
property :external_ip, String
property :port, Fixnum
property :apache_variation, String
property :server_aliases, Array

action_class do
  include BostingGenerator::Helper
end

action :create do
  template "/usr/local/etc/nginx/vhosts/#{user}/#{server_name}.conf" do
    source 'nginx_vhost.conf.erb'
    variables(
        server_names: [server_name].concat(server_aliases),
        ip: ip,
        external_ip: external_ip,
        port: port
    )
    mode 0600
  end

  nginx user do
    action :reload
  end

  template "#{logrotate_base_path}/logrotate.d/#{server_name}" do
    source 'vhost_logrotate.conf.erb'
    variables(
      server_name: server_name,
      user: new_resource.user,
      apache_variation: apache_variation,
      root_group: node['platform'] == 'freebsd' ? 'wheel' : 'root'
    )
  end
end

action :destroy do
  file "/usr/local/etc/nginx/vhosts/#{user}/#{server_name}.conf" do
    action :delete
  end

  nginx user do
    action :reload
  end

  file "#{logrotate_base_path}/logrotate.d/#{server_name}" do
    action :delete
  end
end
