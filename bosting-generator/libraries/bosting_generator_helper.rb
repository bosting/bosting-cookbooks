module BostingGenerator
  module Helper
    def read_array_from_rc_conf(name)
      begin
        line = ::File.readlines('/etc/rc.conf').grep(/^#{name}=/).last.to_s
      rescue Errno::ENOENT
        return []
      end

      match = line.match(/^#{name}="(.*?)"/)
      if match
        match[1].split(' ')
      else
        []
      end
    end

    def mysql_connection_info
      { default_file: '/root/.my.cnf', default_group: 'client' }
    end
  end
end
