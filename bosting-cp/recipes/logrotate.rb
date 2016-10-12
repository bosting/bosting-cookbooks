package 'logrotate'

if node['platform'] == 'freebsd'
  cookbook_file '/usr/local/etc/logrotate.conf' do
    source 'logrotate.conf'
  end

  cron 'logrotate' do
    minute '0'
    command '/usr/local/sbin/logrotate /usr/local/etc/logrotate.conf'
    action :create
  end
end
