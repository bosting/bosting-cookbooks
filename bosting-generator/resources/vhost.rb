resource_name :vhost

property :server_name, String, name_property: true
property :user, String, required: true
property :group, String
property :server_aliases, Array
property :ip, String
property :port, Fixnum
property :directory_index, String
property :show_indexes, [TrueClass, FalseClass]
property :apache_version, String
property :php_version, String

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
        server_alias: server_aliases.join(' '),
        user: new_resource.user,
        ip: ip,
        port: port,
        directory_index: directory_index,
        show_indexes: show_indexes ? 'Indexes' : '',
        php_version: php_version
    )
  end

  apache user do
    apache_version new_resource.apache_version
    action :reload
  end
end

action :destroy do
  file "/usr/local/etc/apache/servers/#{user}/#{server_name}.conf" do
    action :delete
  end

  apache user do
    apache_version new_resource.apache_version
    action :reload
  end

  directory "/home/#{user}/#{server_name}" do
    recursive true
    action :delete
  end
end
