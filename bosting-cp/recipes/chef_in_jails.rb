%w(chef-apply chef-client chef-shell chef-solo).each do |link|
  link "/usr/jails/basejail/usr/bin/#{link}" do
    to "/opt/chef/bin/#{link}"
  end
end

node['bosting-cp']['apache_variations'].each do |jail_name, options|
  jail_base_path = "/usr/jails/#{jail_name}"

  execute "update cookbooks in #{jail_name} jail" do
    command "rsync -avzP --delete /root/cookbooks #{jail_base_path}/root"
  end

  ssh_known_hosts_entry options['ip']

  execute "run chef-client in #{jail_name} jail" do
    json_attributes = JSON.dump({'bosting-hosting' => options})
    command "echo '#{json_attributes}' | ssh root@#{options['ip']} -i /root/.ssh/chef_rsa \"chef-client --local-mode " +
                "--runlist 'recipe[bosting-hosting]' --json-attributes /dev/stdin\" --logfile /var/log/chef-client"
  end
end
