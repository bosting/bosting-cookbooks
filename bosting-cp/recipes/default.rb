#
# Cookbook Name:: bosting-cp
# Recipe:: default
#
# Copyright (c) 2016 Alexander Zubkov, All Rights Reserved.

require 'mysql2'
require 'pg'

::Chef::Recipe.send(:include, BostingCp::Helper)
::Chef::Resource::Template.send(:include, BostingCp::Helper)

install_method = node['bosting-cp']['chef_install_method']
raise "Unknown Chef install method: #{install_method}" unless %w[omnitruck rubygems].include?(install_method)

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
  include_recipe 'bosting-cp::chef_client'
end
include_recipe 'bosting-cp::users'
include_recipe 'bosting-cp::packages'
include_recipe 'bosting-cp::nginx'
include_recipe 'bosting-cp::mysql'
include_recipe 'bosting-cp::pgsql'
include_recipe 'bosting-cp::redis'
include_recipe 'bosting-cp::rails'
include_recipe 'bosting-cp::apache'
include_recipe 'bosting-cp::php_ini'
include_recipe 'bosting-cp::ftp'
include_recipe 'bosting-cp::disable_sendmail'
include_recipe 'bosting-cp::postfix'
include_recipe 'bosting-cp::phpmyadmin'
include_recipe 'bosting-cp::phppgadmin'
include_recipe 'bosting-cp::roundcube'
include_recipe 'bosting-cp::logrotate'
