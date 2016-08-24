#
# Cookbook Name:: bosting-cp
# Recipe:: default
#
# Copyright (c) 2016 Alexander Zubkov, All Rights Reserved.

::Chef::Recipe.send(:include, BostingCp::Helper)

include_recipe 'bosting-cp::hostname'
include_recipe 'bosting-cp::sysctl'
include_recipe 'bosting-cp::profile_d'
if node['platform'] == 'freebsd'
  include_recipe 'bosting-cp::boot_conf'
  include_recipe 'bosting-cp::make_conf'
  include_recipe 'bosting-cp::create_jails'
  include_recipe 'bosting-cp::pf'
  include_recipe 'freebsd::portsnap'
  include_recipe 'bosting-cp::chef_in_jails'
end
include_recipe 'bosting-cp::users'
include_recipe 'bosting-cp::packages'
include_recipe 'bosting-cp::nginx'
include_recipe 'bosting-cp::mysql'
include_recipe 'bosting-cp::rails'
include_recipe 'bosting-cp::apache'
include_recipe 'bosting-cp::phpmyadmin'
include_recipe 'bosting-cp::phppgadmin'
include_recipe 'bosting-cp::roundcube'
