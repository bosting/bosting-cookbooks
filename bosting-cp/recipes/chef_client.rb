directory '/etc/chef' do
  mode 0700
end

cookbook_file '/etc/chef/client.rb' do
  source 'client.rb'
  mode 0600
end

cookbook_file '/usr/local/etc/rc.d/chef-client' do
  source 'chef-client'
  mode 0755
end

service 'chef-client' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end
