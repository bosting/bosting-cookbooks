package 'mc'
package 'zsh'
package 'git'
package 'node'

if node['platform'] == 'freebsd'
  package 'ruby'
  package 'rubygem-gems'

  package 'openssl'
  freebsd_port 'nginx' do
    options dso: false, file_aio: false, ipv6: false, http_addition: false, http_auth_req: false, http_cache: false,
            http_dav: false, http_flv: false, http_gunzip_filter: false, http_mp4: false, http_random_index: false,
            http_realip: false, http_secure_link: false, http_slice: false, http_status: false, http_sub: false,
            mail: false, mail_ssl: false, httpv2: false, stream: false, stream_ssl: false, threads: false, www: false
  end
end

if node['platform'] == 'debian'
  # export DEBIAN_FRONTEND=noninteractive
  # debconf-set-selections <<< "mariadb-server-10.0 mariadb-server/root_password password deploy"
  # debconf-set-selections <<< "mariadb-server-10.0 mariadb-server/root_password_again password deploy"
  # debconf-set-selections <<< "mariadb-server-10.0 mariadb-server/oneway_migration boolean true"
  # apt-get install -y build-essential ruby ruby-dev git mariadb-server-10.0 libmysqlclient-dev nodejs mc
  # gem install bundler
end
