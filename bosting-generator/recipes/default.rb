#
# Cookbook Name:: bosting-generator
# Recipe:: default
#
# Copyright (c) 2016 Alexander Zubkov, All Rights Reserved.

if node['bosting-generator']['queuename'].nil?
  raise RuntimeError, 'File /etc/bosting_name was not created'
end

include_recipe 'bosting-generator::redis'

while (task = $redis.rpop("tasks_for_#{node['bosting-generator']['queuename']}"))
  task = JSON.parse(task)
  type = task['type']
  case type
  when 'system_user'
    system_user task['name'] do
      uid task['uid']
      group task['group']
      action task['action']
    end
  when 'apache'
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
  when 'vhost'
    vhost task['server_name'] do
      user task['user']
      group task['group']
      ip task['ip']
      port task['port']
      server_alias task['server_alias']
      directory_index task['directory_index']
      apache_version task['apache_version']
      php_version task['php_version']
      show_indexes task['show_indexes']
      action task['action']
    end
  else
    raise RuntimeError, "Unknown task type: #{type}"
  end
end
