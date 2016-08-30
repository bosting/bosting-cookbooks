resource_name :system_user

property :name, String, name_property: true
property :uid, Fixnum, required: true
property :group, String, required: true
property :shell, String, required: true

action :create do
  user name do
    uid new_resource.uid
    group new_resource.group
    shell new_resource.shell
    home "/home/#{name}"
  end

  directory "/home/#{name}" do
    owner name
    group new_resource.group
    mode 0750
  end
end

action :destroy do
  user name do
    action :remove
  end

  directory "/home/#{name}" do
    recursive true
    action :delete
  end
end
