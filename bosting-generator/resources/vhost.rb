resource_name :vhost

property :server_name, String, name_property: true
property :user, String, required: true
property :group, String, required: true
property :server_alias, String, required: true
property :ip, String, required: true
property :port, Fixnum, required: true
property :directory_index, String, required: true
property :show_indexes, [TrueClass, FalseClass], required: true
property :php_version, String, required: true

action :create do
  directory "/home/#{user}/#{server_name}" do
    mode 0750
  end

  %w(cgi-bin logs tmp www).each do |dir|
    directory "/home/#{user}/#{server_name}/#{dir}" do
      owner new_resource.user
      group new_resource.group
      mode 0750
    end
  end

  template "/usr/local/etc/apache/servers/#{user}/#{server_name}.conf" do
    source 'apache_vhost.conf.erb'
    mode 0600
    variables(
        server_name: server_name,
        server_alias: server_alias,
        user: new_resource.user,
        ip: ip,
        port: port,
        directory_index: directory_index,
        show_indexes: show_indexes ? 'Indexes' : '',
        php_version: php_version
    )
  end
end

action :destroy do
  directory "/home/#{user}/#{server_name}" do
    resursive true
    action :delete
  end

  file "/usr/local/etc/apache/servers/#{user}/#{server_name}.conf" do
    action :delete
  end
end
