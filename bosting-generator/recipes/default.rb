#
# Cookbook Name:: bosting-generator
# Recipe:: default
#
# Copyright (c) 2016 Alexander Zubkov, All Rights Reserved.

include_recipe 'bosting-generator::redis'

node['bosting-generator']['tasks']['system_users'].each do |obj|
  system_user obj['name'] do
    group obj['group']
    action obj['action']
  end
end

node['bosting-generator']['tasks']['apaches'].each do |obj|
  apache obj['name'] do
    server_admin obj['server_admin']
    user obj['user']
    group obj['group']
    ip obj['ip']
    port obj['port']
    apache_version obj['apache_version']
    start_servers obj['start_servers']
    min_spare_servers obj['min_spare_servers']
    max_spare_servers obj['max_spare_servers']
    max_clients obj['max_clients']
    action obj['action']
  end
end

node['bosting-generator']['tasks']['vhosts'].each do |obj|
  vhost obj['name'] do
    user obj['user']
    group obj['group']
    ip obj['ip']
    port obj['port']
    server_alias obj['server_alias']
    directory_index obj['directory_index']
    php_version obj['php_version']
    show_indexes obj['show_indexes']
    action obj['action']
  end
end
