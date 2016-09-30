service 'sshd' do
  supports restart: true, reload: true, status: true
  action :nothing
end

file '/etc/ssh/sshd_config' do
  content lazy {
    sshd_config_content = ::File.read('/etc/ssh/users/sshd_config')
    Dir.glob('/etc/ssh/users/*.conf').each do |user|
      sshd_config_content.concat ::File.read(user)
    end
    sshd_config_content
  }
  notifies :restart, 'service[sshd]', :immediately
end
