service 'pf' do
  supports restart: true, reload: true, status: true
  action :nothing
end

template '/etc/pf.conf' do
  source 'pf.conf.erb'
  notifies :reload, 'service[pf]'
end

service 'pf' do
  action [:enable, :start]
end
