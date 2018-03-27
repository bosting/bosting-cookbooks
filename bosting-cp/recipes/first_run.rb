# This recipe is not included in default recipe and should be run separately before default recipe

pgsql_version_short = node['bosting-cp']['pgsql_version'].sub('.', '')
mysql_version_short = node['bosting-cp']['mysql_version'].sub('.', '')

case node['platform']
when 'freebsd'
  package "mysql#{mysql_version_short}-server"
  package "postgresql#{pgsql_version_short}-server"
when 'debian'
  package 'mysql-server'
end

chef_gem 'mysql2' do
  compile_time false
end

chef_gem 'pg' do
  version '0.21.0'
  compile_time false
end
