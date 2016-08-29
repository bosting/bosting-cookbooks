resource_name :apache

property :user, String, name_property: true
property :group, String, required: true
property :server_admin, String, required: true
property :ip, String, required: true
property :port, Fixnum, required: true
property :start_servers, Fixnum, required: true
property :min_spare_servers, Fixnum, required: true
property :max_spare_servers, Fixnum, required: true
property :max_clients, Fixnum, required: true
property :apache_version, String, required: true

action_class do
  include BostingGenerator::Helper
end

action :create do
  template "/usr/local/etc/apache/servers/#{user}.conf" do
    source 'httpd.conf.erb'
    mode 0600
    variables(
        user: new_resource.user,
        group: new_resource.group,
        server_admin: server_admin,
        ip: ip,
        port: port,
        start_servers: start_servers,
        min_spare_servers: min_spare_servers,
        max_spare_servers: max_spare_servers,
        max_clients: max_clients
    )
  end

  if node['platform'] == 'freebsd'

  end

  directory "/usr/local/etc/apache/servers/#{user}" do
    mode 0700
  end
end

action :destroy do
  file "/usr/local/etc/apache/servers/#{user}.conf" do
    action :delete
  end

  directory "/usr/local/etc/apache/servers/#{user}" do
    recursive true
    action :delete
  end
end

action :enable do
  if node['platform'] == 'freebsd'
    username = new_resource.user
    profiles = read_array_from_rc_conf("apache#{apache_version}_profiles").concat([username]).uniq

    replace_or_add "add #{username} to apache profiles" do
      path '/etc/rc.conf'
      pattern "^apache#{apache_version}_profiles="
      line "apache#{apache_version}_profiles=\"#{profiles.join(' ')}\""
    end

    append_if_no_line "enable #{username} apache" do
      path '/etc/rc.conf'
      line "apache#{apache_version}_#{username}_enable=\"YES\""
    end

    append_if_no_line "set #{username} configfile" do
      path '/etc/rc.conf'
      line "apache#{apache_version}_#{username}_configfile=\"/usr/local/etc/apache/servers/#{username}.conf\""
    end
  end
end

action :disable do
  if node['platform'] == 'freebsd'
    username = new_resource.user
    profiles = read_array_from_rc_conf("apache#{apache_version}_profiles").delete(username).uniq

    replace_or_add "remove #{username} from apache profiles" do
      path '/etc/rc.conf'
      pattern "^apache#{apache_version}_profiles="
      line "apache#{apache_version}_profiles=\"#{profiles.join(' ')}\""
    end

    delete_lines "disable #{username} apache" do
      path '/etc/rc.conf'
      pattern "^apache#{apache_version}_#{username}_enable=\"YES\""
    end

    delete_lines "remove #{username} configfile" do
      path '/etc/rc.conf'
      pattern "^apache#{apache_version}_#{username}_configfile="
    end
  end
end

action :start do
  service "apache#{apache_version}" do
    start_command "service apache#{apache_version} start #{new_resource.user}"
    status_command "service apache#{apache_version} status #{new_resource.user}"
    action :start
  end
end

action :reload do
  service "apache#{apache_version}" do
    reload_command "service apache#{apache_version} reload #{new_resource.user}"
    status_command "service apache#{apache_version} status #{new_resource.user}"
    action :reload
  end
end

action :stop do
  service "apache#{apache_version}" do
    stop_command "service apache#{apache_version} start #{new_resource.user}"
    status_command "service apache#{apache_version} status #{new_resource.user}"
    action :stop
  end
end
