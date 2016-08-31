default['bosting-generator']['queuename'] = File.exists?('/etc/bosting_name') ? File.read('/etc/bosting_name').strip : nil
