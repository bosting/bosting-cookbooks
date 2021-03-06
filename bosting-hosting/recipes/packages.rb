if node['platform'] == 'freebsd'
  unless ::File.exist?('/usr/local/sbin/pkg')
    execute 'pkg bootstrap' do
      environment 'ASSUME_ALWAYS_YES' => '1'
    end
    execute 'pkg upgrade -y'
  end

  package 'bash'
  package 'dosunix'
  package 'git'
  package 'iftop'
  package 'ImageMagick6'
  package 'iperf'
  package 'lynx'
  package 'mc'
  package 'memcached'
  package 'mercurial'
  package 'mongodb40'
  package 'mysql57-client'
  package 'nano'
  package 'nmap'
  package 'node'
  package 'redis'
  package 'sudo'
  package 'vim'
  package 'w3m'
  package 'webalizer-geoip'
  package 'wget'
  package 'zsh'

  apache_version = node['bosting-hosting']['apache_version']
  apache_version_short = node['bosting-hosting']['apache_version_short']
  supported_apache_versions = %w[22 24]
  raise Chef::Exceptions::Package, "Not supported apache version: #{apache_version}(#{apache_version_short})" unless supported_apache_versions.include?(apache_version_short)
  package "apache#{apache_version_short}"

  php_version = node['bosting-hosting']['php_version']
  php_version_short = node['bosting-hosting']['php_version_short']
  supported_php_versions = %w[55 56 70 71 72 73 74]
  raise Chef::Exceptions::Package, "Not supported php version: #{php_version}" unless supported_php_versions.include?(php_version_short)
  php5 = php_version.match(/^5/)
  php7 = php_version.match(/^7/)

  replace_or_add "set apache default version to #{apache_version} in make.conf" do
    path '/etc/make.conf'
    pattern 'DEFAULT_VERSIONS+=apache=.*'
    line "DEFAULT_VERSIONS+=apache=#{apache_version}"
  end

  replace_or_add "set php default version to #{php_version} in make.conf" do
    path '/etc/make.conf'
    pattern 'DEFAULT_VERSIONS+=php=.*'
    line "DEFAULT_VERSIONS+=php=#{php_version}"
  end

  package "php#{php_version_short}"

  php_extensions = %w[
    bcmath
    bz2
    ctype
    curl
    dom
    exif
    fileinfo
    filter
    ftp
    gd
    gettext
    iconv
    imap
    json
    mbstring
    mysqli
    opcache
    openssl
    pdo
    pdo_mysql
    pdo_pgsql
    pdo_sqlite
    pgsql
    phar
    posix
    pspell
    session
    simplexml
    soap
    sqlite3
    tokenizer
    xml
    xmlreader
    xmlwriter
    xsl
    zip
    zlib
  ]
  if php5
    php_extensions.concat(%w[
      mysql
    ])
  end
  if php7
    php_extensions.concat(%w[
      intl
    ])
  end
  if php_version_short.to_i < 72
    php_extensions.concat(%w[
      mcrypt
    ])
  end
  if php_version_short.to_i < 74
    php_extensions.concat(%w[
      hash
    ])
  end


  php_extensions.each do |php_extension|
    package("php#{php_version_short}-#{php_extension}")
  end

  package 'm4'
  package 'help2man'
  package 'gmake'
  package 'autoconf'
  package 'autoconf-wrapper'
  package 'icu'
  package 're2c'

  pecl_extensions = %w[
    timezonedb
  ]
  if php5
    pecl_extensions.concat(%w[
      intl
      mongo
      pdflib
      rar
    ])
  end
  if php_version_short.to_i >= 72
    pecl_extensions.concat(%w[
      mcrypt
    ])
  end

  pecl_extensions.each do |pecl_extensions|
    freebsd_port("pecl-#{pecl_extensions}")
  end

  mod_php_options = {ipv6: false}
  # mod_php_options[:mailhead] = true if php5
  freebsd_port "mod_php#{php_version_short}" do
    options mod_php_options
  end

  freebsd_port 'mod_rpaf2'
end
