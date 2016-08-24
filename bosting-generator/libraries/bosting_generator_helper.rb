module BostingGenerator
  module Helper
    def read_array_from_rc_conf(name)
      line = begin
               ::File.readlines('/etc/rc.conf').grep(/^#{name}=/)
             rescue Errno::ENOENT
               []
             end.last.to_s

      match = line.match(/^#{name}="(.*?)"/)
      if match
        match[1].split(' ')
      else
        []
      end
    end
  end
end
