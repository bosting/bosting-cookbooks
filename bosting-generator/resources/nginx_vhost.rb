resource_name :nginx_vhost

property :server_name, String, name_property: true
property :user, String, required: true
property :ip, String, required: true
property :external_ip, String, required: true
property :port, Fixnum, required: true
property :server_aliases, Array, required: true

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
end

action :destroy do
  file "/usr/local/etc/nginx/vhosts/#{user}/#{server_name}.conf" do
    action :delete
  end

  nginx user do
    action :reload
  end
end
