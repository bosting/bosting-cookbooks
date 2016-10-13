package 'logrotate'

if node['platform'] == 'freebsd'
  cookbook_file '/usr/local/etc/logrotate.conf' do
    source 'logrotate.conf'
  end

  cron 'logrotate' do
    minute '25'
    hour '6'
    command '/usr/local/sbin/logrotate /usr/local/etc/logrotate.conf'
    action :create
  end
end
