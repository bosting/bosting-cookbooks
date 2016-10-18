package 'redis'

redis_password = generate_random_password

file '/root/redis_password' do
  sensitive true
  mode 0600
  content redis_password
  action :create_if_missing
end

if node['platform'] == 'freebsd'
  dest_path = '/usr/local/etc/redis.conf'

  node['bosting-cp']['apache_variations'].each_key do |jail_name|
    file "/usr/jails/#{jail_name}/root/redis_password" do
      sensitive true
      mode 0600
      content redis_password
      action :create_if_missing
    end
  end

  ips = node['bosting-cp']['apache_variations'].values.map{ |v| v['ip'] }.concat(['127.0.0.1']).join(' ')
  replace_or_add "bind Redis to #{ips}" do
    path dest_path
    pattern '^bind'
    line "bind #{ips}"
    notifies :restart, 'service[redis]'
  end
end

if node['platform'] == 'debian'
  dest_path = '/etc/redis.conf'
end

replace_or_add 'Set Redis password' do
  sensitive true
  path dest_path
  pattern '^# requirepass'
  line lazy { "requirepass #{::File.read('/root/redis_password').strip}" }
  notifies :restart, 'service[redis]'
end

service 'redis' do
  supports restart: true, reload: true, status: true
  action [:enable, :start]
end
