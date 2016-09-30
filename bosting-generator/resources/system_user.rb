resource_name :system_user

property :name, String, name_property: true
property :uid, Fixnum
property :group, String
property :shell, String
property :chroot_directory, String
property :hashed_password, String

action :create do
  user name do
    uid new_resource.uid
    group new_resource.group
    shell new_resource.shell
    home "/home/#{name}"
    password hashed_password
  end

  directory "/home/#{name}" do
    owner new_resource.name
    mode 0750
  end

  unless chroot_directory.empty?
    template "/etc/ssh/users/#{name}.conf" do
      source 'ssh_user.erb'
      variables(
        name: new_resource.name,
        chroot_directory: chroot_directory
      )
    end
    include_recipe 'bosting-cp::sshd_config'
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

  unless chroot_directory.empty?
    file "/etc/ssh/users/#{name}.conf" do
      action :delete
    end
    include_recipe 'bosting-cp::sshd_config'
  end
end
