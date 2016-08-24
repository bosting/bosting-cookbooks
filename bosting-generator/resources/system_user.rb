resource_name :system_user

property :name, String, name_property: true
property :group, String, required: true
property :uid, Fixnum, required: true
property :shell, String, required: true

action :create do
  user name do
    uid uid
    group new_resource.group
    shell shell
    home "/home/#{name}"
  end

  directory "/home/#{name}" do
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
