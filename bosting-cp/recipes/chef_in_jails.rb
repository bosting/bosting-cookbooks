chef_install_method = node['bosting-cp']['chef_install_method']

if chef_install_method == 'omnitruck'
  %w[chef-apply chef-client chef-shell chef-solo].each do |link|
    link "/usr/jails/basejail/usr/bin/#{link}" do
      to "/opt/chef/bin/#{link}"
    end
  end
end

node['bosting-cp']['apache_variations'].each do |jail_name, options|
  jail_base_path = "/usr/jails/#{jail_name}"

  execute "update cookbooks in #{jail_name} jail" do
    command "rsync -avzP --delete /root/cookbooks #{jail_base_path}/root"
  end

  ssh_known_hosts_entry options['ip']

  if chef_install_method == 'rubygems'
    execute "install Ruby in #{jail_name} jail" do
      command "ssh root@#{options['ip']} -i /root/.ssh/chef_rsa " \
                '"setenv ASSUME_ALWAYS_YES yes && pkg install -y ruby rubygem-gems"'
      creates "/usr/jails/#{jail_name}/usr/local/bin/gem"
    end

    execute "install Chef in #{jail_name} jail" do
      chef_version = node['bosting-cp']['chef_version']
      command "ssh root@#{options['ip']} -i /root/.ssh/chef_rsa gem install chef -v #{chef_version}"
      creates "/usr/jails/#{jail_name}/usr/local/bin/chef-client"
    end
  end

  execute "run chef-client in #{jail_name} jail" do
    json_attributes = JSON.dump({
      'bosting-hosting' => options,
      'bosting-cp'      => {
        'chef_install_method' => chef_install_method
      }
    })
    command "echo '#{json_attributes}' | ssh root@#{options['ip']} -i /root/.ssh/chef_rsa \"chef-client --local-mode " \
                "--runlist 'recipe[bosting-hosting]' --json-attributes /dev/stdin\" --logfile /var/log/chef-client"
  end
end
