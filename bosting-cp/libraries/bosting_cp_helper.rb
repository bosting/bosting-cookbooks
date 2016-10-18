module BostingCp
  module Helper
    def add_nullfs_to_jail(path, jail_name)
      jail_base_path = "/usr/jails/#{jail_name}"
      mountpoint = "#{jail_base_path}#{path}"

      directory(mountpoint) { recursive true }

      fstab = "/etc/fstab.#{jail_name}"
      append_if_no_line "add #{path} to #{fstab}" do
        path fstab
        line "#{path} #{mountpoint} nullfs rw 0 0"
      end
    end

    # todo: remove duplication, already defined in app/modules/concerns/password_generator.rb
    def generate_random_password(length = 16)
      chars = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
      (0...length).map{ chars[SecureRandom.random_number(chars.length)] }.join
    end

    def generate_blowfish_secret
      Digest::SHA1.hexdigest(IO.read('/dev/urandom', 2048))
    end

    def symbolize_keys(hash)
      return hash.inject({}){|memo,(k,v)| memo[k.to_sym] =  symbolize_keys(v); memo} if hash.is_a? Hash
      return hash.inject([]){|memo,v    | memo           << symbolize_keys(v); memo} if hash.is_a? Array
      return hash
    end
  end
end
