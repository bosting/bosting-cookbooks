case node['bosting-cp']['chef_install_method']
when 'omnitruck'
  command  = '/usr/bin/chef-client'
  procname = '/opt/chef/embedded/bin/ruby'
when 'rubygems'
  command  = '/usr/local/bin/chef-client'
  procname = '/usr/local/bin/ruby24'
end

directory '/etc/chef' do
  mode 0o700
end

cookbook_file '/etc/chef/client.rb' do
  source 'client.rb'
  mode 0o600
end

template '/usr/local/etc/rc.d/chef-client' do
  source 'chef-client.erb'
  mode 0o755
  variables(
    command:  command,
    procname: procname
  )
end

service 'chef-client' do
  supports status: true, restart: true, reload: true
  action %i[enable start]
end
