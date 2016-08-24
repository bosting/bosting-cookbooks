group 'webuser' do
  gid 1000
end

group 'www' do
  gid 8080
end

user 'www' do
  uid 80
  gid 8080
  comment 'World Wide Web Owner'
  home '/nonexistent'
  shell '/usr/sbin/nologin'
end

link '/home' do
  to '/usr/home'
end
