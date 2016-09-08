resource_name :nginx

property :user, String, name_property: true

action :create do
  file "/usr/local/etc/nginx/vhosts/#{user}.conf" do
    content "include /usr/local/etc/nginx/vhosts/#{new_resource.user}/*.conf;"
    mode 0600
  end

  directory "/usr/local/etc/nginx/vhosts/#{user}" do
    mode 0700
  end

  nginx user do
    action :reload
  end
end

action :destroy do
  file "/usr/local/etc/nginx/vhosts/#{user}.conf" do
    action :delete
  end

  directory "/usr/local/etc/nginx/vhosts/#{user}" do
    recursive true
    action :delete
  end

  nginx user do
    action :reload
  end
end

action :reload do
  service 'nginx' do
    supports(restart: true, reload: true, status: true)
    action :reload
  end
end
