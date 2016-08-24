cookbook_file '/etc/profile' do
  source 'bash_profile'
end

file '/etc/zprofile' do
  content 'source /etc/profile'
end
