#
# Cookbook Name:: bosting-hosting
# Recipe:: default
#
# Copyright (c) 2016 Alexander Zubkov, All Rights Reserved.

node.set['bosting-hosting']['apache_version_short'] = node['bosting-hosting']['apache_version'].sub('.', '')
node.set['bosting-hosting']['php_version_short'] = node['bosting-hosting']['php_version'].sub('.', '')

include_recipe 'bosting-cp::make_conf'
include_recipe 'bosting-cp::users'
include_recipe 'bosting-hosting::packages'
include_recipe 'bosting-hosting::apache'
include_recipe 'bosting-cp::disable_sendmail'
include_recipe 'bosting-hosting::ssmtp'
include_recipe 'bosting-cp::php_ini'
include_recipe 'bosting-cp::chef_client'
