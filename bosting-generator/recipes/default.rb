#
# Cookbook Name:: bosting-generator
# Recipe:: default
#
# Copyright (c) 2016 Alexander Zubkov, All Rights Reserved.

if node['bosting-generator']['queuename'].nil?
  raise RuntimeError, 'File /etc/bosting_name was not created'
end

include_recipe 'bosting-generator::redis'

is_nginx = node['bosting-generator']['queuename'] == 'root'

while (task = $redis.rpop("tasks_for_#{node['bosting-generator']['queuename']}"))
  task = JSON.parse(task)
  type = task['type']
  case type
  when 'system_user'
    system_user task['name'] do
      uid task['uid']
      group task['group']
      shell task['shell']
      hashed_password task['hashed_password']
      chroot_directory task['chroot_directory']
      action task['action']
    end
  when 'apache'
    if is_nginx
      nginx task['user'] do
        action task['action']
      end
    else
      if task['action'] == 'create'
        task['action'] = ['create', 'enable', 'start', 'reload']
      elsif task['action'] == 'destroy'
        task['action'] = ['stop', 'disable', 'destroy']
      end
      apache task['user'] do
        server_admin task['server_admin']
        group task['group']
        ip task['ip']
        port task['port']
        apache_version task['apache_version']
        start_servers task['start_servers']
        min_spare_servers task['min_spare_servers']
        max_spare_servers task['max_spare_servers']
        max_clients task['max_clients']
        action task['action']
      end
    end
  when 'vhost'
    if is_nginx
      nginx_vhost task['server_name'] do
        user task['user']
        ip task['ip']
        external_ip task['external_ip']
        port task['port']
        server_aliases task['server_aliases']
        action task['action']
      end
    else
      vhost task['server_name'] do
        user task['user']
        group task['group']
        ip task['ip']
        port task['port']
        server_aliases task['server_aliases']
        directory_index task['directory_index']
        apache_version task['apache_version']
        php_version task['php_version']
        show_indexes task['show_indexes']
        action task['action']
      end
    end
  when 'mysql_user'
    mysql_user task['login'] do
      hashed_password task['hashed_password']
      action task['action']
    end
  when 'mysql_db'
    mysql_db task['db_name'] do
      mysql_user task['mysql_user']
      action task['action']
    end
  else
    raise RuntimeError, "Unknown task type: #{type}"
  end
end
