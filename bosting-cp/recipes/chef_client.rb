cookbook_file '/usr/local/etc/rc.d/chef-client' do
  source 'chef-client'
  mode 0755
end

service 'chef-client' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end
